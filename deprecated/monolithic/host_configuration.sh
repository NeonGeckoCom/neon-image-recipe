# any optional tweaks done to the base image

# disable hdmi, helps in power saving
# /usr/bin/tvservice -o

# set gpu memory to minimum, we dont use gpu (no GUI) and ram is shared with cpu
#grep -q "gpu_mem=16" /boot/config.txt || \
#  echo "gpu_mem=16" >> /boot/config.txt

# expand filesystem
#sudo raspi-config --expand-rootfs

# disable wifi power management
sudo iwconfig wlan0 power off

# setup
# setup zram swap
# https://haydenjames.io/raspberry-pi-performance-add-zram-kernel-parameters/
git clone https://github.com/foundObjects/zram-swap.git
cd zram-swap && sudo ./install.sh && cd ..
#sudo cp ./etc/sysctl.conf /etc/sysctl.conf

# change hostname
hostn=$(cat /etc/hostname)
newhost="neon"

sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname


# clean bash history
history -c
