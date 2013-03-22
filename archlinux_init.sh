#!/bin/sh

# Options

hostname=picue

# Host setup
cd
echo $hostname > /etc/hostname
ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

passwd <<EOF
picue$hostname
picue$hostname
EOF

if [ -f "/var/lib/pacman/db.lck" ]; then
	echo "Package lock file '/var/lib/pacman/db.lck' exists. Please cleanup previous failed instalation before running."
	exit
fi

# TODO: check and if possible grow main partition
do_expand_rootfs() {
	pacman --noconfirm -S parted
	#SOURCE: https://github.com/asb/raspi-config/blob/master/raspi-config
  fdisk /dev/mmcblk0 <<EOF
p
d
2
n
p
2


p
w
EOF
partprobe
resize2fs /dev/mmcblk0p2
}

pacman --noconfirm -Syu
pacman-key --init
pacman --noconfirm -S xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev mesa xf86-input-evdev
pacman --noconfirm -S alsa-firmware alsa-utils
pacman --noconfirm -S vim sudo awesome git rxvt-unicode tmux gnu-netcat zsh ttf-liberation
pacman --noconfirm -S base-devel

echo 'urxvt &
exec awesome' > .xinitrc

if lspci 2> /dev/null | grep -c VirtualBox; then
	pacman --noconfirm -S openssh virtualbox-guest-utils
	systemctl start sshd
	modprobe -a vboxguest vboxsf vboxvideo
	echo "vboxguest
	vboxsf
	vboxvideo" > /etc/modules-load.d/virtualbox.conf
	#echo 'VBoxClient-all &' >> .xinitrc
fi

#if [ $(uname -m) == "armv6l" ]; then
#	curl -L http://goo.gl/1BOfJ > /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
#	rpi-update
#fi

if git clone git://github.com/alerque/picue.git; then
	cd picue
	makepkg --asroot --noconfirm -s -i
fi
