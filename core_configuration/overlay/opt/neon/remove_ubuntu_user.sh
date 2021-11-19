#!/bin/bash

userdel -r ubuntu
rm -rf /home/ubuntu
rm /opt/neon/remove_ubuntu_user
systemctl disable remove_ubuntu_user