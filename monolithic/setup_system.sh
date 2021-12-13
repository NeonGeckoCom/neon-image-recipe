#!/bin/bash
## create user
#if [ "${USER}" != "neon" ]; then
#  sudo adduser neon --gecos "" --disabled-password
#  echo "neon:neon" | sudo chpasswd
#  sudo chage -d 0 neon
#fi

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# create directories
sudo cp -rf overlay/* / || exit 2

# setup network manager
sudo touch /etc/dhcpd.conf
grep -q "denyinterfaces wlan0" /etc/dhcpcd.conf || \
  echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf

sudo systemctl daemon-reload

# Enable neon services
sudo systemctl enable neon_firstboot.service
sudo systemctl enable neon.service
sudo systemctl enable neon-gui-shell.service
