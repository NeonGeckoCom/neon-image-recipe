#!/bin/bash

# Install system dependencies
sudo apt install -y gcc make python3-pip i2c-tools
sudo pip install smbus smbus2 spidev rpi.gpio

# Build and load VocalFusion Driver
git clone https://github.com/OpenVoiceOS/vocalfusiondriver
cd vocalfusiondriver/driver || exit 10
make all
sudo mkdir /lib/modules/5.4.0-1028-raspi/kernel/drivers/vocalfusion
sudo cp vocalfusion* /lib/modules/5.4.0-1028-raspi/kernel/drivers/vocalfusion
sudo depmod -a
# modinfo vocalfusion-soundcard should show the module info now
cd .. || exit 10
sudo cp xvf3510.dtbo /boot/firmware/overlays

# Copy required overlay files
cd -P "$( dirname "${BASH_SOURCE[0]}" )" || exit 10
sudo cp -r overlay/* /
sudo chmod -R ugo+x /usr/bin

# Overwrite Pulse Config
sudo rm /etc/pulse/system.pa
sudo rm /etc/pulse/daemon.conf
sudo ln -s /etc/pulse/mycroft-sj201-daemon.conf /etc/pulse/daemon.conf
sudo ln -s /etc/pulse/mycroft-sj201-default.pa /etc/pulse/system.pa

echo "Add 'dtoverlay=xvf3510' line to /boot/firmware/config.txt"
