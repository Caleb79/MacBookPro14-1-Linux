# CS8409 Audio Fix

## Symptome

- CS8409 Analog wird erkannt
- speaker-test läuft
- kein Ton
- Phantom Jack Einträge

## Ursache

Falsche oder fehlende Ubuntu HWE Kernelquellen.

## Lösung

1. Ubuntu HWE Tag ermitteln
2. sound/hda aus Launchpad Git holen
3. linux-source-7.0.0.tar.bz2 erzeugen
4. snd_hda_macbookpro installieren
5. Neustart

## Erfolgreich getestet mit

Kernel:
7.0.0-31-generic

Ubuntu HWE Tag:
Ubuntu-hwe-7.0-7.0.0-31.31_24.04.1
