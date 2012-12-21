#!/bin/sh

echo picue > /etc/hostname
ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

pacman --noconfirm -Syu
pacman-key --init
pacman --noconfirm -S xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev mesa
pacman --noconfirm -S alsa-firmware alsa-utils alsa-oss
pacman --noconfirm -S vim sudo awesome git

if lspci | grep -c VirtualBox; then
	pacman --noconfirm -S openssh virtualbox-guest-utils
	modprobe -a vboxguest vboxsf vboxvideo
	echo "vboxguest
	vboxsf
	vboxvideo" > /etc/modules-load.d/virtualbox.conf
	# echo 'VBoxClient-all &' > .xinitrc
fi

if [ ! -f /usr/bin/rpi-update ]; then
	curl http://goo.gl/1BOfJ > /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
	rpi-update
fi
