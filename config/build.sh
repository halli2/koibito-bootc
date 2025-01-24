#!/usr/bin/bash

set -ouex pipefail

# set up justfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KOI_DIR=/usr/share/koibito

cp $SCRIPT_DIR/kust /usr/bin/

mkdir -p $KOI_DIR/just

for FILE in $SCRIPT_DIR/just/*; do
  cp $FILE $KOI_DIR/just/
done

cp $SCRIPT_DIR/justfile $KOI_DIR/justfile
for FILE in $KOI_DIR/just/*; do
  echo "import '$FILE'" >> $KOI_DIR/justfile
done

# Services
mkdir -p /usr/etc/systemd/user
cp $SCRIPT_DIR/fcitx5.service /usr/etc/systemd/user/
cp $SCRIPT_DIR/easyeffects.service /usr/etc/systemd/user/
