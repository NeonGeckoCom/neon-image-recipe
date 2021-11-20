#!/bin/bash
BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}"/.. || exit 10
sudo rm -r "${BASE_DIR}" || exit 2
sudo rm /etc/NetworkManager/system-connections/*
sudo touch /opt/neon/resize_fs
sudo shutdown
history -c