#!/bin/bash
HOMEDIR="$(eval echo "~$SUDO_USER")"
DIRECTORY=$HOMEDIR/chroot
if [ -d "$DIRECTORY" ]; then
    rm -rf $DIRECTORY
fi
mkdir $DIRECTORY
sudo -u $SUDO_USER mkarchroot $DIRECTORY/root base-devel
cp /etc/pacman.conf $DIRECTORY/root/etc/
