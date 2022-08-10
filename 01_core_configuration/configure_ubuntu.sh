#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

cp -r overlay/* /
chmod -R ugo+x /opt/neon

# Add 'neon' user with default password
adduser neon --gecos "" --disabled-password
echo "neon:neon" | chpasswd
passwd --expire neon

# Add any expected groups
groupadd gpio
groupadd pulse
groupadd pulse-access
groupadd i2c
groupadd dialout

# Add neon user to groups
usermod -aG sudo neon
usermod -aG gpio neon
usermod -aG video neon
usermod -aG input neon
usermod -aG render neon
usermod -aG pulse neon
usermod -aG pulse-access neon
usermod -aG i2c neon
usermod -aG dialout neon

# Add root user to groups
usermod -aG pulse root
usermod -aG pulse-access root

# Enable new services
systemctl enable resize_fs.service

# Set TZ
echo "America/Los_Angeles" > /etc/timezone
rm /etc/localtime
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# Change Hostname
sed -i "s|ubuntu|neon|g" /etc/hosts
sed -i "s|ubuntu|neon|g" /etc/hostname

echo "Core Configuration Complete"
