# MacBookPro14,1 Linux

Linux Mint with a MacBook Pro 13" 2017 (MacBookPro14,1).

## Hardware

- Model: MacBookPro14,1
- CPU: Intel i5-7360U
- Audio: Cirrus Logic CS8409
- WiFi: Broadcom BCM4350

## Status

| component | status |
|------------|---------|
| WiFi | ✅ |
| Audio | ✅ |
| Keyboard | ✅ |
| Trackpad | ✅ |
| Keyboard backlighting | ✅ |
| Bluetooth | ✅ |
| Suspend modus | ✅ |

## Suspend and resume

Suspend and resume work after disabling PCIe D3cold for the Apple NVMe
controller at `0000:01:00.0`.

See:

- docs/hardware/suspend-resume.md
- systemd/apple-nvme-d3cold.service

## Wesentliche Erkenntnis

For CS8409 audio to work properly on Ubuntu/Mint HWE kernels,
`snd_hda_macbookpro` must be built against the exact matching Ubuntu HWE kernel sources.

details:

- docs/audio/cs8409-audio-fix.md
