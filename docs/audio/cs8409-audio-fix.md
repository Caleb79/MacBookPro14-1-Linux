# CS8409 Audio Fix

## Symptoms

- CS8409 analog is recognized
- speaker-test operates
- no sound
- phantom jack connectors

## root cause

Wrong or missing Ubuntu HWE kernel sources.

## Soloution

1. determine Ubuntu HWE tag
2. grab sound/hda from Launchpad Git
3. create linux-source-7.0.0.tar.bz2
4. install snd_hda_macbookpro
5. Reboot

## Successfully tested with

Kernel:
7.0.0-31-generic

Ubuntu HWE Tag:
Ubuntu-hwe-7.0-7.0.0-31.31_24.04.1
