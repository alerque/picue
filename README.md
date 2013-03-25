picue
=====

Setup Lyricue on a Raspberry Pi

1. Download archlinux image via [this torrent](http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2013-02-11/archlinux-hf-2013-02-11.zip.torrent).

2. Unzip image and write to SD card

        unzip archlinux-hf-2013-02-11.zip
        dd bs=1M if=archlinux-hf-2013-02-11.img of=/dev/sdX

3. Move SD card to Pi and boot it

4. Login via ssh or console

    root/root

4. Execute init script to configure archlinux with a graphical interface

        sh <(curl https://raw.github.com/alerque/picue/master/archlinux_init.sh)
	
	or

		sh <(curl -L http://goo.gl/xxGyv)

        reboot

5. Build and install lyricue
