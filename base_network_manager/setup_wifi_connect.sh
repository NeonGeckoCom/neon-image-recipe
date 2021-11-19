#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# Replace netplan with network-manager
sudo apt update
sudo apt purge -y netplan.io
sudo apt install -y network-manager

# Setup all the services
sudo systemctl stop systemd-networkd.socket
sudo systemctl disable systemd-networkd.socket
sudo systemctl stop systemd-networkd
sudo systemctl disable systemd-networkd
sudo systemctl enable network-manager

# Add wifi-connect binary
sudo cp -r overlay/* /
sudo chmod -R ugo+x /usr/local/sbin
sudo chmod -R ugo+x /opt/neon

# Configure networking check on startup and restart
sudo systemctl enable wifi-setup.service
