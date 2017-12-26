#!/bin/bash
DIRECTORY=~/chroot
if [ -d "$DIRECTORY" ]; then
    sudo rm -rf $DIRECTORY
fi
mkdir $DIRECTORY
mkarchroot $DIRECTORY/root base-devel openh264
sudo cp /etc/pacman.conf $DIRECTORY/root/etc/
