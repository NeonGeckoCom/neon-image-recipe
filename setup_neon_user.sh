#!/bin/bash

# Add 'neon' user
sudo groupadd gpio
sudo adduser neon --gecos "" --disabled-password
echo "neon:neon" | sudo chpasswd
sudo usermod -aG sudo neon
sudo usermod -aG gpio neon
sudo usermod -aG video neon
sudo usermod -aG input neon
sudo usermod -aG render neon
echo "Added sudo user 'neon' remove Ubuntu user on next boot"
#sudo deluser ubuntu
#sudo rm -rf /home/ubuntu
