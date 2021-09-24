#!/bin/bash
# Remove ubuntu user
sudo deluser ubuntu
sudo rm -rf /home/ubuntu
sudo shutdown && sudo chage -d 0 neon
history -c
