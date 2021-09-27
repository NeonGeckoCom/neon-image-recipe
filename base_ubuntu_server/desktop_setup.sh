#!/bin/bash

# Ubuntu Server Deps
sudo apt update
sudo apt upgrade
sudo apt install -y xorg openbox portaudio19-dev

# Configure desktop settings
sudo gsettings set org.gnome.desktop.screensaver lock-enabled false
sudo gsettings set org.gnome.desktop.session idle-delay 0
sudo sed -i "s/#  AutomaticLoginEnable = true/  AutomaticLoginEnable = true/" /etc/gdm3/custom.conf
sudo sed -i "s/#  AutomaticLogin = user1/  AutomaticLogin = neon/" /etc/gdm3/custom.conf

# setup X desktop environment
sudo cp ./etc/profile.d/configure_x.sh /etc/profile.d/configure_x.sh
sudo chmod +x /etc/profile.d/configure_x.sh

# Add 'neon' user
sudo adduser neon --gecos "" --disabled-password
echo "neon:neon" | sudo chpasswd
sudo usermod -aG sudo neon
echo "Added sudo user 'neon' remove Ubuntu user on next boot"

sudo cp -r ./var /
sudo cp -r ./usr /
