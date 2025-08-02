 # raspi-audio

Turn your Raspberry Pi into a bluetooth audio receiver and Spotify device. Uses the internal Bluetooth chip.

Tested with a Raspberry Pi 4, Debian Bookworm 12.12 OS and Scarlett 2i2 Focusrite soundcard

## Installation Instructions

```bash  
# download the files
$ wget https://github.com/lucas-broido/raspi-audio/blob/main/install.sh
$ wget https://github.com/lucas-broido/raspi-audio/blob/main/set_card_num.sh

# run the setup
$ bash setup.sh
```

After the installation, make sure to reboot your device with:

```
$ sudo reboot
```
----


**NOTE**: the bluetooth audio has a slight latency so this setup is suited for playing audio only and not watching videos