# this is executed on host in first run of a brand new image!

# disable wifi power management
sudo iwconfig wlan0 power off

# clean bash history
history -c
