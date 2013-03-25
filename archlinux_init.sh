#!/bin/sh

# Options
hostname=picue


# Get off on the right foot
cd
test "$UID" -eq 0 || flunk "Need to be root"

function flunk () {
	echo $*
	exit 1
}


case $1 in
	1|host)
		# Host setup
		echo $hostname > /etc/hostname
		ln -sf /usr/share/zoneinfo/Turkey /etc/localtime
		echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
		locale-gen

		passwd <<- EOF
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
		partprobe
		resize2fs /dev/mmcblk0p2
		}

		# TODO: find out if this is even legit any more now that Arch as some pi specific packages
		#if [ $(uname -m) == "armv6l" ]; then
		#	curl -L http://goo.gl/1BOfJ > /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
		#	rpi-update
		#fi

		pacman --noconfirm -Syu
		pacman-key --init
		pacman --noconfirm -S xorg-server xorg-xinit xorg-server-utils xf86-video-fbdev mesa xf86-input-evdev
		pacman --noconfirm -S alsa-firmware alsa-utils
		pacman --noconfirm -S vim sudo awesome git rxvt-unicode tmux gnu-netcat zsh ttf-liberation
		pacman --noconfirm -S base-devel
		pacman --noconfirm -S mysql
	;;
	vmode)
		pacman -S fbset
		function setvmode() {
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
			pacman --noconfirm -S openssh virtualbox-guest-utils
			systemctl start sshd
			modprobe -a vboxguest vboxsf vboxvideo
			echo "vboxguest
			vboxsf
			vboxvideo" > /etc/modules-load.d/virtualbox.conf
			#echo 'VBoxClient-all &' >> .xinitrc
		fi
	;;
	3|build)
		pushd $PWD
		if [ -d "~/picue" ]; then
			cd picue
			git pull
		else
			git clone git://github.com/alerque/picue.git
			cd picue
		fi
		makepkg --asroot --noconfirm -s -i
		popd
	;;
	4|user)
		echo 'urxvt &
		exec awesome' > .xinitrc
	;;
	5|data)
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
	;;
esac
