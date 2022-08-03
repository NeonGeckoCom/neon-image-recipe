#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

kernel=$(ls /lib/modules)
#kernel="5.4.0-1052-raspi"

# Install system dependencies
apt update
apt install -y gcc make python3-pip i2c-tools libraspberrypi-bin pulseaudio pulseaudio-module-zeroconf alsa-utils
CFLAGS="-fcommon" pip install smbus smbus2 spidev rpi.gpio


# Build and load VocalFusion Driver
git clone https://github.com/OpenVoiceOS/vocalfusiondriver
cd vocalfusiondriver/driver || exit 10
sed -ie "s|\$(shell uname -r)|${kernel}|g" Makefile
make all || exit 2
mkdir "/lib/modules/${kernel}/kernel/drivers/vocalfusion"
cp vocalfusion* "/lib/modules/${kernel}/kernel/drivers/vocalfusion" || exit 2
# /usr/lib/modules/5.4.0-1028-raspi/extra/
depmod ${kernel} -a
# `modinfo -k ${kernel} vocalfusion-soundcard` should show the module info now
#cd .. || exit 10
#mkdir /boot/firmware/overlays
#cp xvf3510.dtbo /boot/firmware/overlays

# Add gpio group for rules
groupadd gpio

# Copy required overlay files
cd ${BASE_DIR} || exit 10
cp -r overlay/* /
chmod -R ugo+x /usr/bin
chmod -R ugo+x /usr/sbin
chmod ugo+x /opt/neon/configure_sj201_on_boot.sh

# Overwrite Pulse Config
#mv /etc/pulse/default.pa /etc/pulse/default.pa.bak
#mv /etc/pulse/daemon.conf /etc/pulse/daemon.conf.bak

#mv /etc/pulse/mycroft-sj201-daemon.conf /etc/pulse/daemon.conf
#mv /etc/pulse/mycroft-sj201-default.pa /etc/pulse/default.pa
#mv /etc/pulse/mycroft-sj201-default.pa /etc/pulse/system.pa

# Ensure python bin exists for added scripts
if [ ! -f "/usr/bin/python" ]; then
  ln -s /usr/bin/python3 /usr/bin/python
fi

# Configure card 1x
#/opt/neon/configure_sj201_on_boot.sh

# Enable system services
#systemctl enable pulseaudio.service
# TODO: System service won't load audio devices??
systemctl enable sj201

echo "Setup Complete"
