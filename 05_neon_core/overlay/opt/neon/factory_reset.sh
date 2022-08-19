#!/usr/bin/env bash
sudo rm -rf /home/neon/.neon
sudo rm -rf /home/neon/neon
#sudo rm -rf /etc/neon
sudo rm -rf /var/log/neon
sudo mkdir -p /var/log/neon
mkdir -p /home/neon/neon /home/neon/.neon /tmp/neon
chown 1000:1000 /home/neon/neon /home/neon/.neon /tmp/neon /var/log/neon
