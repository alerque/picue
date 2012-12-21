picue
=====

Setup Lyricue on a Raspberry Pi

1. Download archlinux image via [this torrent](http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2012-09-18/archlinux-hf-2012-09-18.zip.torrent).

2. Unzip image and write to SD card

    unzip archlinux-hf-2012-09-18.zip
    dd bs=1M if=archlinux-hf-2012-09-18.img of=/dev/sdX

3. Move SD card to Pi and boot it

4. Login via ssh or console

root/root

4. Execute init script:

    sh <(curl https://github.com/alerque/picue/blob/master/archlinux_init.sh)
    reboot
