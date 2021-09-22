#!/bin/bash

sudo apt install -y gcc make

git clone https://github.com/OpenVoiceOS/vocalfusiondriver
cd vocalfusiondriver/driver || exit 10
make all
sudo mkdir /lib/modules/5.4.0-1028-raspi/kernel/drivers/vocalfusion
sudo cp vocalfusion* /lib/modules/5.4.0-1028-raspi/kernel/drivers/vocalfusion
sudo depmod -a
# modinfo vocalfusion-soundcard should show the module info now
cd .. || exit 10
sudo cp xvf3510.dtbo /boot/firmware/overlays
echo "Add 'dtoverlay=xvf3510' line to /boot/firmware/config.txt"

pip install smbus2

# TODO: Copy overlay files