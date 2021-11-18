#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

kernel=$(uname -r)

# Install system dependencies
sudo apt update
sudo apt install -y gcc make python3-pip i2c-tools libraspberrypi-bin pulseaudio pulseaudio-module-zeroconf
sudo CFLAGS="-fcommon" pip install smbus smbus2 spidev rpi.gpio

# Build and load VocalFusion Driver
git clone https://github.com/OpenVoiceOS/vocalfusiondriver
cd vocalfusiondriver/driver || exit 10
make all
sudo mkdir "/lib/modules/${kernel}/kernel/drivers/vocalfusion"
sudo cp vocalfusion* "/lib/modules/${kernel}/kernel/drivers/vocalfusion" || exit 10
# /usr/lib/modules/5.4.0-1028-raspi/extra/
sudo depmod -a
# modinfo vocalfusion-soundcard should show the module info now
cd .. || exit 10
sudo cp xvf3510.dtbo /boot/firmware/overlays

# Add gpio group for rules
sudo groupadd gpio

# Copy required overlay files
cd .. || exit 10
sudo cp -r overlay/* /
sudo chmod -R ugo+x /usr/bin
sudo chmod -R ugo+x /usr/sbin
sudo chmod ugo+x /opt/neon/configure_sj201_on_boot.sh

# Overwrite Pulse Config
sudo mv /etc/pulse/default.pa /etc/pulse/default.pa.bak
sudo mv /etc/pulse/daemon.conf /etc/pulse/daemon.conf.bak
sudo mv /etc/pulse/mycroft-sj201-daemon.conf /etc/pulse/daemon.conf
sudo mv /etc/pulse/mycroft-sj201-default.pa /etc/pulse/default.pa
sudo mv /etc/pulse/mycroft-sj201-default.pa /etc/pulse/system.pa

# Ensure python bin exists for added scripts
if [ ! -f "/usr/bin/python" ]; then
  sudo ln -s /usr/bin/python3 /usr/bin/python
fi

# Configure card 1x
sudo /opt/neon/configure_sj201_on_boot.sh

# Enable system services
sudo systemctl enable sj201
sudo systemctl enable pulseaudio

echo "Setup Complete"
