#!/bin/bash
# Remove ubuntu user
sudo deluser ubuntu
sudo rm -rf /home/ubuntu

# Remove saved Networks
sudo rm /etc/NetworkManager/system-connections/*

sudo shutdown
history -c
