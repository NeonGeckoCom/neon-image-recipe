#!/bin/bash
## create user
#if [ "${USER}" != "neon" ]; then
#  sudo adduser neon --gecos "" --disabled-password
#  echo "neon:neon" | sudo chpasswd
#  sudo chage -d 0 neon
#fi

# create directories
#sudo mkdir -p /var/log/neon
sudo mkdir -p /opt/neon
sudo mkdir -p /etc/neon

# copy system configs
sudo cp ./etc/neon/neon.conf /etc/neon/neon.conf
sudo cp ./etc/neon/holmes.conf /etc/neon/holmes.conf


# setup audio config files
sudo cp ./etc/asound.conf /etc/asound.conf
sudo cp ./etc/pulse/system.pa /etc/pulse/system.pa

sudo usermod -aG pulse neon
sudo usermod -aG pulse-access neon
sudo usermod -aG pulse root
sudo usermod -aG pulse-access root
sudo usermod -aG i2c neon
sudo usermod -aG input neon

# setup network manager
sudo cp ./etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
sudo touch /etc/dhcpd.conf
grep -q "denyinterfaces wlan0" /etc/dhcpcd.conf || \
  echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf

# setup launchers
sudo cp -r ./opt/neon /opt
sudo chmod +x /opt/neon/*.sh

# setup systemd
sudo cp ./usr/lib/systemd/system/*.service /usr/lib/systemd/system
sudo cp ./usr/sbin/first_boot.sh /usr/sbin/first_boot.sh
sudo chmod +x /usr/sbin/first_boot.sh
sudo chmod +x /usr/lib/systemd/system/neon*

sudo systemctl daemon-reload
#sudo systemctl enable pulseaudio.service

sudo systemctl enable neon_firstboot.service

# Copy user config overlay files and enable user services
cp -r ./home/.config/* /home/neon/.config
systemctl --user enable neon.service
systemctl --user enable neon-gui.service

# Shell customizations
cp -f ./home/.bashrc /home/neon/

# Ensure home directory ownership
sudo chown -R neon:neon /home/neon
