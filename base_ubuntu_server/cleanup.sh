#!/bin/bash
# Remove ubuntu user
sudo deluser ubuntu
sudo rm -rf /home/ubuntu
sudo shutdown
history -c
