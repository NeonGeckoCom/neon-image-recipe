#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

sudo cp -r overlay/* /
sudo chmod -R ugo+x /opt/neon

# Add 'neon' user
sudo groupadd gpio
sudo adduser neon --gecos "" --disabled-password
echo "neon:neon" | sudo chpasswd
sudo usermod -aG sudo neon
sudo usermod -aG gpio neon
sudo usermod -aG video neon
sudo usermod -aG input neon
sudo usermod -aG render neon

sudo systemctl daemon-reload
sudo systemctl enable remove_ubuntu_user.service