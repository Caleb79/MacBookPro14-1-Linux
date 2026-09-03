# Audio Fix MacBookPro14,1 under Linux Mint 24.04

## Problem

CS8409 Analog device appears, but:

- no sound from speakers
- no sound from headphones
- speaker-test runs without errors
- only "Phantom Jack" devices shown

## Root Cause

The snd_hda_macbookpro installer fails on Ubuntu/Mint HWE kernels because
/usr/src/linux-source-7.0.0.tar.bz2 is missing.

The driver must be built against the exact Ubuntu HWE kernel sources from Launchpad,
not against a generic kernel.org source tree.
