# Suspend and Resume Fix

This page documents the suspend and resume fix for Linux Mint on a
13-inch MacBook Pro from 2017.

## Tested hardware

- Model: MacBookPro14,1
- Device: MacBook Pro 13-inch, 2017, without Touch Bar
- Storage: Apple SSD AP0256J
- NVMe PCI address: `0000:01:00.0`
- Wi-Fi: Broadcom BCM4350
- Audio: Cirrus Logic CS8409

## Tested software

- Linux Mint based on Ubuntu 24.04
- Ubuntu HWE kernel 7.0.x
- Tested with kernel `7.0.0-31-generic`
- Deep suspend enabled

## Problem

Suspend appeared to start, but resume was unreliable.

Observed symptoms included:

- Keyboard backlight remained active during suspend.
- The display sometimes required approximately two minutes to return.
- The lock screen occasionally appeared and accepted the password.
- Wi-Fi disappeared shortly after resume.
- Applications became unresponsive.
- Executing local programs could result in an input/output error.
- The system eventually displayed a black screen or blinking cursor.
- A hard reset was required.

One particularly useful error was:

```text
bash: /usr/bin/top: Input/output error
```

This indicated that the Wi-Fi failure was likely a secondary symptom.
The system was unable to reliably access data from the root filesystem
after resume.

## Suspend mode

The available suspend modes can be checked with:

```bash
cat /sys/power/mem_sleep
```

The result should show:

```text
s2idle [deep]
```

The brackets indicate that `deep` is active.

The active kernel command line can be checked with:

```bash
cat /proc/cmdline
```

The relevant GRUB configuration is:

```text
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off mem_sleep_default=deep"
```

After changing `/etc/default/grub`, apply the configuration with:

```bash
sudo update-grub
sudo reboot
```

After rebooting, verify both settings:

```bash
cat /proc/cmdline
cat /sys/power/mem_sleep
```

## Diagnosis

The Apple SSD is exposed as an NVMe controller at PCI address
`0000:01:00.0`.

Verify the PCI address with:

```bash
lspci -nnk | grep -A4 -i 'non-volatile\|nvme'
```

The relationship can also be confirmed in the kernel log:

```bash
sudo dmesg | grep -i nvme
```

Expected output includes:

```text
nvme nvme0: pci function 0000:01:00.0
```

The installed storage devices can be listed with:

```bash
lsblk -o NAME,MODEL,SIZE
```

Example:

```text
NAME        MODEL               SIZE
nvme0n1     APPLE SSD AP0256J 233.8G
├─nvme0n1p1                     512M
└─nvme0n1p2                   233.3G
nvme0n2     APPLE SSD AP0256J     8K
```

## Root cause

The Apple NVMe controller did not reliably recover when the PCIe device
was allowed to enter the `D3cold` power state.

`D3cold` is a PCIe device power state in which the device can be powered
down almost completely. The device must be fully initialized again
during resume.

On this MacBook, the Apple NVMe controller could enter `D3cold`, but did
not return reliably after deep suspend.

This resulted in:

- Filesystem input/output errors
- Applications no longer starting
- Wi-Fi disappearing as system services became unstable
- Audio or desktop components becoming unavailable
- A complete system freeze

## Temporary workaround

Disable `D3cold` for the Apple NVMe controller:

```bash
echo 0 | sudo tee /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
```

Verify the value:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
```

Expected result:

```text
0
```

Test suspend:

```bash
systemctl suspend
```

After resume, verify:

```bash
nmcli device status
aplay -l
top
```

Also test:

- Internal speakers
- Volume keys
- Keyboard
- Touchpad
- Wi-Fi
- Bluetooth
- Opening applications
- Reading files from the root filesystem

## Permanent systemd service

Create a systemd service that disables `D3cold` during every boot.

Create the file:

```bash
sudo nano /etc/systemd/system/apple-nvme-d3cold.service
```

Add the following content:

```ini
[Unit]
Description=Disable D3cold for Apple NVMe SSD
Documentation=https://github.com/
After=sys-fs-sysfs.mount
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'test -e /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed && echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

The `test -e` check prevents the service from failing if the expected PCI
device is temporarily unavailable or the hardware configuration changes.

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable and start the service:

```bash
sudo systemctl enable --now apple-nvme-d3cold.service
```

Check the service:

```bash
systemctl status apple-nvme-d3cold.service
```

Verify the active value:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
```

Expected result:

```text
0
```

## Verification after reboot

Restart the computer:

```bash
sudo reboot
```

After rebooting, check:

```bash
systemctl is-enabled apple-nvme-d3cold.service
systemctl is-active apple-nvme-d3cold.service
cat /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
cat /sys/power/mem_sleep
```

Expected results:

```text
enabled
active
0
s2idle [deep]
```

Run several suspend and resume cycles:

```bash
systemctl suspend
```

After each resume, verify:

```bash
nmcli device status
rfkill list
aplay -l
top
```

The workaround was considered successful when repeated suspend cycles
completed with:

- A smooth transition to a dark display
- Successful resume
- Working Wi-Fi
- Working Bluetooth
- Working internal audio
- Working keyboard and touchpad
- No input/output errors
- No black screen
- No hard reset required

## Removing the workaround

Disable the service:

```bash
sudo systemctl disable --now apple-nvme-d3cold.service
```

Remove the service file:

```bash
sudo rm /etc/systemd/system/apple-nvme-d3cold.service
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

The kernel default can be restored for the current boot by writing `1`:

```bash
echo 1 | sudo tee /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
```

## Troubleshooting

### Service is active but the value is still 1

Check the service log:

```bash
journalctl -u apple-nvme-d3cold.service -b
```

Verify that the PCI address still exists:

```bash
test -e /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed \
  && echo "Apple NVMe PCI device found" \
  || echo "Apple NVMe PCI device not found"
```

List the NVMe PCI controller:

```bash
lspci -nnk | grep -A4 -i 'non-volatile\|nvme'
```

### Deep suspend is not active

Check:

```bash
cat /sys/power/mem_sleep
cat /proc/cmdline
```

If `s2idle` is selected, update `/etc/default/grub`:

```text
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off mem_sleep_default=deep"
```

Then run:

```bash
sudo update-grub
sudo reboot
```

### Suspend testing mode is still active

Check:

```bash
cat /sys/power/pm_test
```

The expected normal state is:

```text
[none] core processors platform devices freezer
```

Reset it if necessary:

```bash
echo none | sudo tee /sys/power/pm_test
```

### Collect logs after a failed resume

After a hard reset, inspect the previous boot:

```bash
sudo journalctl -k -b -1 > suspend-kernel.log
```

Search for relevant messages:

```bash
grep -Ei \
  'suspend|resume|PM:|nvme|I/O|ext4|pci|pcie|brcm|applespi|error|failed|timeout' \
  suspend-kernel.log
```

A failed resume may leave the journal ending at:

```text
PM: suspend entry (deep)
```

because the kernel is unable to write further messages after the storage
path becomes unavailable.

## Notes

The following NVMe parameter was tested but did not solve the issue:

```text
nvme_core.default_ps_max_latency_us=0
```

In the tested configuration, this parameter made resume behavior worse and
was removed from GRUB.

The working GRUB configuration remained:

```text
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off mem_sleep_default=deep"
```

The effective fix was specifically:

```text
/sys/bus/pci/devices/0000:01:00.0/d3cold_allowed = 0
```

## Result

With `D3cold` disabled for the Apple NVMe controller:

- Deep suspend works
- Resume works
- Wi-Fi remains available
- Bluetooth remains available
- Internal audio continues working
- Applications start normally
- No filesystem input/output errors occur
- The system remains stable after resume
