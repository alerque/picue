picue
=====

	version=alpha

The easy way to setup a lyricue display server on a Raspberry Pi:

1. Download the lastest ArchLinux disk image via [this torrent](http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2013-02-11/archlinux-hf-2013-02-11.zip.torrent).

2. Unzip the image and copy it to an SD card (at least 2GB)

        unzip archlinux-hf-2013-02-11.zip
        dd bs=1M if=archlinux-hf-2013-02-11.img of=/dev/sdX

3. Put the SD card in your Pi and boot it up.

4. Login via ssh or console

    	Username: root
		Password: root

4. Download and execute the setup script in one easy step that will auto configure the ArchLinux envoronment, compile Lyricue and configure the output:

        sh <(curl https://raw.github.com/alerque/picue/master/archlinux_init.sh)
	
	or the short URL version if you are typing on the console:

		sh <(curl -L http://goo.gl/xxGyv)

5. Wait a while. The system will reboot twice in the process of setting everything up.

6. Welcome to your Lyricue display.

picue on VirtualBox
=====

1. Download the latest ARchLinux iso image via [this torrent](https://www.archlinux.org/releng/releases/2013.04.01/torrent/)

2. Create a new machine in VirtualBox

  * Type: Linux
  * Version: ArchLinux
  * Memory: 256 MB
  * Hard Drive: 4 GB

3. Connect the CD drive image to the iso file downloaded above

4. Continue with #4 above […]
