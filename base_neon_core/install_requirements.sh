#!/bin/bash

if [ -z "${GITHUB_TOKEN}" ]; then
  echo "GITHUB_TOKEN not specified!"
  exit 1
fi

sudo add-apt-repository -y ppa:deadsnakes/ppa

# Add mimic repo
sudo apt install -y curl
curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | sudo apt-key add - 2> /dev/null && \
echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" | sudo tee /etc/apt/sources.list.d/mycroft-desktop.list

# install system packages
sudo apt-get update
sudo apt-get install -y  alsa-utils \
     libasound2 libasound2-plugins \
     pulseaudio pulseaudio-utils \
     sox libsox-fmt-all mimic libpulse-dev \
     python3.7 python3-pip python3.7-venv python3.7-dev \
     network-manager swig libfann-dev gcc mpg123 wireless-tools || \
     exit 1

# This will break cloud-init networking! (Even upon re-installing apt package)
#sudo apt remove -y python3-yaml  TODO: Consider removing this in wifi-setup step DM

python3.7 -m venv "/home/neon/venv" || exit 10
. /home/neon/venv/bin/activate
pip install --upgrade pip~=21.1.0
pip install wheel
pip install "git+https://${GITHUB_TOKEN}@github.com/NeonGeckoCom/NeonCore#egg=neon_core[pi,dev,client]" || exit 1

# Copy overlay files (default configuration)
cd ../../.. || exit 10
sudo cp -rf overlay/* / || exit 2
sudo chown -R neon:neon /home/neon

neon-install-default-skills

# Disable wifi service and let the skill handle it
sudo systemctl disable wifi-setup.service
echo "neon ALL = (ALL) NOPASSWD: /usr/local/sbin/wifi-connect" | sudo EDITOR='tee -a' visudo
# TODO: Consider installing DS model here DM

# TODO: This is a patch for ovos-core DM
sudo mkdir -p /opt/mycroft
sudo chown neon:neon /opt/mycroft

# Setup Completed
echo "Setup Complete"
exit 0
