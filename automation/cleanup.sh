#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}/build" || exit 10

# Re-enable restart prompts
sudo mv mnt/etc/apt/apt.conf.d/.99needrestart mnt/etc/apt/apt.conf.d/99needrestart
sudo mv mnt/root/bashrc mnt/root/.bashrc
sudo rm -rf mnt/tmp/*
echo "Temporary files removed"
sudo umount mnt/run/systemd/resolve || exit 10
sudo umount mnt || exit 10
echo "Image unmounted"
rm -r mnt