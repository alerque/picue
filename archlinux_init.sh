#!/bin/sh

# Options
hostname=picue
timezone=Turkey

# Generic stuff we're always going to need
flunk() {
	echo "$@"
	exit 1
}

set_retry_flag() {
	retry_flag=true
}

# Get off on the right foot. We don't know where we're coming from
retry_flag=
cd /root
test "$UID" -eq 0 || flunk "Need to be root"

# Setup is a little different in VirtualBox than on the Raspberry Pi
if lspci 2> /dev/null | grep -c VirtualBox; then
	vbox=true
else
	vbox=false
fi

reboot_and_continue() {
	if mount | grep -q 'sda1 on /mnt'; then
		prefix=/mnt
		cmd="arch-chroot /mnt"
	else
		prefix=
		cmd=
	fi
	curl -L http://goo.gl/xxGyv > $prefix/root/picue-setup.sh
	chmod 755 $prefix/root/picue-setup.sh
	cat <<- EOF > $prefix/usr/lib/systemd/system/picue-setup.service
		[Unit]
		Description=Picue setup script post-reboot continue script
		ConditionPathExists=/root/picue-setup.sh
		Requires=network.target
		After=network.target
		
		[Service]
		Type=oneshot
		TimeoutSec=0
		StandardOutput=tty
		RemainAfterExit=yes
		ExecStart=/root/picue-setup.sh

		[Install]
		WantedBy=multi-user.target
		EOF
	$cmd systemctl --no-reload enable picue-setup
	test -z "$prefix" || umount /mnt
	reboot
	exit
}

if [ -f "/var/lib/pacman/db.lck" ]; then
	flunk "Package lock file '/var/lib/pacman/db.lck' exists. Please cleanup previous failed instalation before running."
fi

# Functions, see Logic to make the magic happen
init_vbox() {
	if [ "$(blkid -o value -s TYPE /dev/loop0)" = "squashfs" ]; then
		if [ ! -b "/dev/sda1" ]; then
			fdisk /dev/sda <<- EOF
				n
				p
				1


				w
				EOF
				partprobe /dev/sda
		fi
		if [ -z "$(blkid -o value -s TYPE /dev/sda1)" ]; then
			mkfs.ext4 /dev/sda1
		fi
		if ! mount | grep -q sda1; then
			mkdir -p /mnt
			mount /dev/sda1 /mnt
		fi
		if [ ! -f "/mnt/etc/fstab" ]; then
			pacstrap /mnt base
			arch-chroot /mnt pacman --noconfirm -S syslinux
			genfstab -p /mnt >> /mnt/etc/fstab
			arch-chroot mkinitcpio -p linux
		fi
		reboot_and_continue
	fi
}
init_host() {
	# Host setup
	echo $hostname > /etc/hostname

	ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

	if ! locale -a | grep -q en_US.utf8 ; then
		cat <<- EOF > /etc/locale.gen
			en_US.UTF-8 UTF-8
			EOF
		locale-gen
	fi

	passwd <<- EOF
		picue$hostname
		picue$hostname
		EOF

	pacman --noconfirm -Syu || flunk "Can't get caught up with ArchLinux"
	pacman-key --init

	which partprobe || pacman --noconfirm -S parted || flunk "Could not find or get partprobe"
	end=$(parted /dev/mmcblk0 -ms unit s p | grep "^2" | cut -f 3 -d: | cut -f 1 -ds)
	max=$(($(parted /dev/mmcblk0 -ms unit s p | grep "^/" | cut -f 2 -d: | cut -f 1 -ds) - 1))
	if [ $end -lt $max ]; then
		fdisk /dev/mmcblk0 <<- EOF
			p
			d
			2
			n
			p
			2


			p
			w
			EOF
		reboot_and_continue
	else
		resize2fs /dev/mmcblk0p2
	fi

	return

	# TODO: find out if this is even legit any more now that Arch as some pi specific packages
	#if [ $(uname -m) == "armv6l" ]; then
	#	curl -L http://goo.gl/1BOfJ > /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
	#	rpi-update
	#fi
}

install_packages() {
	pacman --noconfirm -S --needed xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev xf86-input-evdev mesa 
	pacman --noconfirm -S --needed alsa-firmware alsa-utils
	pacman --noconfirm -S --needed zsh vim sudo git tmux gnu-netcat
	pacman --noconfirm -S --needed awesome rxvt-unicode ttf-liberation
	pacman --noconfirm -S --needed mysql
	#pacman --noconfirm -S --needed tigervnc
}

build_pkg() {
	pushd $PWD
	cd
	pacman --noconfirm -S --needed base-devel
	if [ -d "$1" ]; then
		cd $1
		git pull
	else
		git clone git://github.com/alerque/$1.git
		cd $1
	fi
	makepkg --asroot --noconfirm -s -i
	popd
}

setup_mysql() {
	systemctl enable mysqld
	systemctl start mysqld
	/usr/bin/mysqladmin -u root password "picue$hostname"
	/usr/bin/mysqladmin -u root -h picue password "picue$hostname"
	#TODO: Use this instead
	#/usr/bin/mysql_secure_installation

	return

	mysql < /usr/share/lyricue/mysql/Create_lyricDb.sql
	mysql < /usr/share/lyricue/mysql/Create_mediaDb.sql

	wget http://www.lyricue.org/bible_files/MySQL_create_bible_NASB.sql.gz -O /tmp/bible.sql.gz
	gzip -dc /tmp/bible.sql.gz | mysql

	mysql -e "GRANT ALL ON lyricDb.* TO 'lyric'@'%';"
	mysql -e "GRANT ALL ON mediaDb.* TO 'lyric'@'%';"
	mysql -e "GRANT ALL ON bibleDb.* TO 'lyric'@'%';"
	mysql -e "GRANT ALL ON lyricDb.* TO ''@'%';"
	mysql -e "GRANT ALL ON mediaDb.* TO ''@'%';"
	mysql -e "GRANT ALL ON bibleDb.* TO ''@'%';"
}

configure_x() {
	cat <<- EOF > ~/.xinitrc
		urxvt &
		exec awesome
		EOF
	mkdir -p ~/.local/share/lyricue
	cat <<- EOF > ~/.local/share/lyricue/config2
		Main = Sans 40
		Header = Sans 20
		Footer = Sans 20
		OSD = Sans 30
		Colour = #ffffff
		ShadowColour = #000000
		ShadowSize = 2
		Height = 800
		Width = 1280
		OverscanH = 0
		OverscanV = 0
		Loop = 1
		Audit = 1
		DynamicPreview = 1
		Miniview = 0
		Xinerama = 1
		CentreX = 1
		CentreY = 1
		BGImage = 1
		SpecialSong = Today's Announcements
		SpecialImage = Solid
		SpecialBack = Solid
		ImageDirectory = ~/Pictures
		BGDirectory = ~/Pictures
		HorizontalLocation = Centre
		VerticalLocation = Centre
		Justification = Left
		TrayIcons = 1
		DatabaseType = mysql
		DefBible =
		App = OpenOffice Impress;ooimpress
		App = Movie Player;totem
		Preset1 = Used with permission CCLI 23232
		Preset2 = Used without permission
		EOF
}

# Logic
if [ ! "$vbox" = "true" ]; then
	init_vbox || set_retry_flag
fi
init_host || set_retry_flag
install_packages || set_retry_flag
build_pkg picue || set_retry_flag
if [ ! "$vbox" = "true" ]; then
	build_pkg fbvnc || set_retry_flag
fi
setup_mysql || set_retry_flag
configure_x || set_retry_flag

if [ "$retry_flag" = "true" ]; then
	echo "At least one operation failed, will reboot and try again in 1 minute"
	sleep 60
	reboot_and_continue
fi

# Cleanup after ourselves
if [ -f "/usr/lib/systemd/system/picue-setup.service" ]; then
	systemctl --no-reload disable picue-setup
	rm /usr/lib/systemd/system/picue-setup.service
fi

exit

#old stuff
case $1 in
	fbdev_driver)
		pacman --noconfirm -S --needed fbset
		setvmode() {
			cat <<- EOF >> /boot/config.txt
			framebuffer_depth=32
			framebuffer_ignore_alpha=1
			gpu_mem_256=112
			gpu_mem_512=368
			cma_lwm=16
			cma_hwm=32
			cma_offline_start=16
			EOF
		}
	;;
	2|vbox)
		if lspci 2> /dev/null | grep -c VirtualBox; then
			pacman --noconfirm -S --needed openssh virtualbox-guest-utils
			systemctl start sshd
			modprobe -a vboxguest vboxsf vboxvideo
			echo "vboxguest
			vboxsf
			vboxvideo" > /etc/modules-load.d/virtualbox.conf
			#echo 'VBoxClient-all &' >> .xinitrc
		fi
	;;
esac
