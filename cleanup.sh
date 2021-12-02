#!/bin/bash
BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove recipe dir
cd "${BASE_DIR}"/.. || exit 10
sudo rm -r "${BASE_DIR}" || exit 2

# Remove any saved networks
sudo rm /etc/NetworkManager/system-connections/*

# Remove any neon logs
sudo systemctl stop neon.service
rm -rf ~/.local/share/neon/logs/

# Ensure FS is resized on next boot for compressed images
sudo touch /opt/neon/resize_fs

# Shutdown and clear BASH history
sudo shutdown
history -c