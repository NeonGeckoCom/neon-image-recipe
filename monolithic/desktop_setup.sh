#!/bin/bash

# Ubuntu Server Deps
sudo apt update
sudo apt install -y xorg openbox portaudio19-dev

# Configure desktop settings
sudo gsettings set org.gnome.desktop.screensaver lock-enabled false
sudo gsettings set org.gnome.desktop.session idle-delay 0
sudo sed -i "s/#  AutomaticLoginEnable = true/  AutomaticLoginEnable = true/" /etc/gdm3/custom.conf
sudo sed -i "s/#  AutomaticLogin = user1/  AutomaticLogin = neon/" /etc/gdm3/custom.conf
# TODO: Need to configure power settings manually
echo "Change Default DE and Power Settings after reboot"
#echo -e"[SeatDefaults]\nautologin-user=neon" | sudo tee /etc/lightdm/lightdm.conf.d/50-myconfig.conf
