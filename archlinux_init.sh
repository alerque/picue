#!/bin/sh

echo picue > /etc/hostname
ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

pacman --noconfirm -Syu
pacman --noconfirm -S xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev mesa
pacman --noconfirm -S alsa-firmware alsa-utils alsa-oss
pacman --noconfirm -S vim sudo awesome

if [ ! -f /usr/bin/rpi-update ]; then
	wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
	rpi-update
fi
