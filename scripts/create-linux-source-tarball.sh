#!/bin/bash

TAG="$1"

git clone --depth 1 \
  --branch "$TAG" \
  --filter=blob:none \
  --sparse \
  https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/noble \
  ubuntu-kernel-src

cd ubuntu-kernel-src
git sparse-checkout set sound/hda

sudo tar -cjf /usr/src/linux-source-7.0.0.tar.bz2 \
  --transform 's,^sound,linux-source-7.0.0/sound,' \
  sound/hda
