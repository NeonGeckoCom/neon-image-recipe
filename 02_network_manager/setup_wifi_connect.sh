#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# Replace netplan with network-manager
apt update
apt purge -y netplan.io
apt install -y network-manager

# Setup all the services
#systemctl stop systemd-networkd.socket
systemctl disable systemd-networkd.socket
#systemctl stop systemd-networkd
systemctl disable systemd-networkd
systemctl enable network-manager

# Add wifi-connect binary
cp -r overlay/* /
chmod -R ugo+x /usr/local/sbin
chmod -R ugo+x /opt/neon

# Configure networking check on startup and restart
systemctl enable wifi-setup.service

# Patch SSH service
cd /etc/ssh
ssh-keygen -A
sed -ie "s|PasswordAuthentication no|PasswordAuthentication yes|g" /etc/ssh/sshd_config
