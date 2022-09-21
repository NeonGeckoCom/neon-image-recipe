#!/bin/bash
# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

dist=$(grep "^Distributor ID:" <<<"$(lsb_release -a)" | cut -d':' -f 2 | tr -d '[:space:]')
codename=$(grep "^Codename:" <<<"$(lsb_release -a)" | cut -d':' -f 2 | tr -d '[:space:]')

# Ensure Rasbperry Pi Sources are available
apt update

apt install -y libraspberrypi-bin
if [ $? != 0 ]; then
    echo "Adding raspberry pi apt sources"
    apt install -y curl
    curl http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add - 2> /dev/null
    if [ "${codename}" == "bullseye" ]; then
        echo "deb http://archive.raspberrypi.org/debian/ bullseye main" | tee /etc/apt/sources.list.d/raspberrypi.list
    elif [ "${codename}" == "bookworm" ]; then
        echo "deb http://archive.raspberrypi.org/debian/ bookworm main" | tee /etc/apt/sources.list.d/raspberrypi.list
    fi
fi

# Install system dependencies
apt update
apt install -y libraspberrypi-bin || echo "Failed to install libraspberrypi"

if [ "${dist}" == 'Debian' ]; then
    echo "Installing linux headers"
    apt install -y linux-headers-arm64
fi

apt install -y gcc make python3-pip i2c-tools pulseaudio pulseaudio-module-zeroconf alsa-utils git
CFLAGS="-fcommon" pip install smbus smbus2 spidev rpi.gpio

# Determine kernel with build directory
kernels=($(ls /lib/modules))
for k in "${kernels[@]}"; do
    if [ -d "/lib/modules/${k}/build" ]; then
        kernel=k
    fi
done
if [ -z ${kernel} ]; then
    echo "No build files available. Picking kernel=${kernels[0]}"
    kernel=${kernels[0]}
fi
#kernel="5.4.0-1052-raspi"

# Build and load VocalFusion Driver
git clone https://github.com/OpenVoiceOS/vocalfusiondriver
cd vocalfusiondriver/driver || exit 10
sed -ie "s|\$(shell uname -r)|${kernel}|g" Makefile
make all || exit 2
mkdir "/lib/modules/${kernel}/kernel/drivers/vocalfusion"
cp vocalfusion* "/lib/modules/${kernel}/kernel/drivers/vocalfusion" || exit 2
depmod ${kernel} -a
# `modinfo -k ${kernel} vocalfusion-soundcard` should show the module info now

# Configure pulse user
usermod -aG bluetooth pulse

# Disable userspace pulseaudio services
systemctl --global disable pulseaudio.service pulseaudio.socket

# Copy required overlay files
cd ${BASE_DIR} || exit 10
cp -r overlay/* /
chmod -R ugo+x /usr/bin
chmod -R ugo+x /usr/sbin
chmod ugo+x /opt/neon/configure_sj201_on_boot.sh

# Ensure python bin exists for added scripts
if [ ! -f "/usr/bin/python" ]; then
  ln -s /usr/bin/python3 /usr/bin/python
fi

# Enable system services
systemctl enable pulseaudio.service
systemctl enable sj201
systemctl enable sj201-shutdown

echo "Audio Setup Complete"
