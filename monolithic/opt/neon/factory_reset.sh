#!/usr/bin/env bash
sudo rm -rf /home/pi/.neon
sudo rm -rf /home/pi/neon
#sudo rm -rf /etc/neon
sudo rm -rf /var/log/neon
sudo mkdir -p /var/log/neon
mkdir -p /home/pi/neon /home/pi/.neon /tmp/neon
chown 1000:1000 /home/pi/neon /home/pi/.neon /tmp/neon /var/log/neon
