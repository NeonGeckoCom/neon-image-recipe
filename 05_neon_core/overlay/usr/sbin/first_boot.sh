# this is executed on host in first run of a brand new image!

# disable hdmi, helps in power saving
# /usr/bin/tvservice -o

# set gpu memory to minimum, we dont use gpu (no GUI) and ram is shared with cpu
#grep -q "gpu_mem=16" /boot/config.txt || \
#  echo "gpu_mem=16" >> /boot/config.txt

## expand filesystem
#sudo raspi-config --expand-rootfs

# disable wifi power management
sudo iwconfig wlan0 power off

# clean bash history
history -c
