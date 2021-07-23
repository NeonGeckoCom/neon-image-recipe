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

usermod -aG pulse neon
usermod -aG pulse-access neon
usermod -aG pulse root
usermod -aG pulse-access root

# setup network manager
sudo cp ./etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
grep -q "denyinterfaces wlan0" /etc/dhcpcd.conf || \
  echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

# setup launchers
sudo cp -r ./opt/neon /opt
chmod +x /opt/neon/*.sh

# setup systemd
sudo cp ./usr/lib/systemd/system/*.service /usr/lib/systemd/system
sudo cp ./usr/sbin/first_boot.sh /usr/sbin/first_boot.sh
chmod +x /usr/sbin/first_boot.sh
chmod +x /usr/lib/systemd/system/neon*
chmod +x /usr/lib/systemd/system/pulseaudio.service

sudo systemctl daemon-reload
sudo systemctl enable pulseaudio.service 
sudo systemctl enable neon.service
sudo systemctl enable neon_firstboot.service

# GUI auto-launch
echo -e"xset -dpms\nxset s off\nxset s noblank\nmycroft-gui-app --hideTextInput --maximize" | sudo tee /etc/profile.d/start_gui.sh
sudo chmod ugo+x /etc/profile.d/start_gui.sh
