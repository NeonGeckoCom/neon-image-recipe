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

default_username="neon"  # Default user to create
default_password="neon"
image_name="neon"  # Identifier for extra directories and hostname

apt update
apt install -y lsb-release cloud-guest-utils

dist=$(grep "^Distributor ID:" <<<"$(lsb_release -a)" | cut -d':' -f 2 | tr -d '[:space:]')

# Debos image will already have FS overlay and groups configured
if [ "${dist}" == 'Ubuntu' ]; then
    cp -r overlay/* /
    chmod -R ugo+x /opt/${image_name}
    # Add any expected groups
    groupadd gpio
    groupadd pulse
    groupadd pulse-access
    groupadd i2c
    groupadd dialout

    # Add root user to groups
    usermod -aG pulse root
    usermod -aG pulse-access root

    # Enable new services
    systemctl enable resize_fs.service

    # Disable extraneous services
    systemctl disable snapd.service
fi

# Add 'neon' user with default password
adduser "${default_username}" --gecos "" --disabled-password
echo "${default_username}:${default_password}" | chpasswd
passwd --expire ${default_username}

if [ ! -f "/home/${default_username}/.profile" ]; then
    echo ".profile missing for added user"
    ls /etc/skel || exit 10
    cp -r /etc/skel/ "/home/${default_username}"
    chown -R ${default_username}:${default_username} "/home/${default_username}"
fi

# Add neon user to groups
usermod -aG sudo ${default_username}
usermod -aG gpio ${default_username}
usermod -aG video ${default_username}
usermod -aG input ${default_username}
usermod -aG render ${default_username}
usermod -aG pulse ${default_username}
usermod -aG pulse-access ${default_username}
usermod -aG i2c ${default_username}
usermod -aG dialout ${default_username}
usermod -aG netdev ${default_username}


# Set TZ
echo "America/Los_Angeles" > /etc/timezone
rm /etc/localtime
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# TODO: Can below be simplified?
if [ "${dist}" == 'Ubuntu' ]; then
    echo "Updating Device Hostname"
    # Change Hostname
    sed -i "s|ubuntu|${image_name}|g" /etc/hosts
    sed -i "s|ubuntu|${image_name}|g" /etc/hostname
else
    echo "${image_name}" > /etc/hostname
fi

echo "Core Configuration Complete"
