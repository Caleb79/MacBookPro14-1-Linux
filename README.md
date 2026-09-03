# MacBookPro14,1 Linux

Linux Mint auf einem MacBook Pro 13" 2017 (MacBookPro14,1).

## Hardware

- Modell: MacBookPro14,1
- CPU: Intel i5-7360U
- Audio: Cirrus Logic CS8409
- WLAN: Broadcom BCM4350

## Status

| Komponente | Status |
|------------|---------|
| WLAN | ✅ |
| Audio | ✅ |
| Tastatur | ✅ |
| Trackpad | ✅ |
| Tastaturbeleuchtung | ✅ |
| Bluetooth | ✅ |

## Wesentliche Erkenntnis

Für funktionierendes CS8409-Audio unter Ubuntu/Mint HWE-Kernels
muss `snd_hda_macbookpro` gegen die exakt passenden Ubuntu-HWE-Kernelquellen gebaut werden.

Details siehe:

- docs/audio/cs8409-audio-fix.md
