#!/bin/bash

image_file=${1}
if [ -z ${image_file} ]; then
    echo "No file specified to mount"
fi

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}/build" || exit 10

mkdir boot
mkdir mnt

echo "Copying Boot Overlay Files"
sudo mount -o loop,offset=1048576 ${image_file} boot || exit 10
sudo cp -r ${BASE_DIR}/../00_boot_overlay/ubuntu_22_04/* boot/
sudo umount boot
rm -r boot
echo "Boot Files Configured"

echo "Mounting Image FS"
sudo mount -o loop,offset=269484032 ${image_file} mnt || exit 10
sudo mkdir -p mnt/run/systemd/resolve
sudo mount --bind /run/systemd/resolve mnt/run/systemd/resolve  && echo "Mounted resolve directory from host" || exit 10

echo "Copying Image scripts"
cp -r ${BASE_DIR}/../01_core_configuration mnt/tmp/
cp -r ${BASE_DIR}/../02_network_manager mnt/tmp/
cp -r ${BASE_DIR}/../03_sj201 mnt/tmp/
cp -r ${BASE_DIR}/../04_embedded_shell mnt/tmp/
cp -r ${BASE_DIR}/../05_neon_core mnt/tmp/

# Copy interactive script into base image
cp ${BASE_DIR}/run_scripts.sh mnt/tmp

# Configure bashrc so script runs on login (chroot)
if [ "${2}" == "-y" ]; then
    echo "Configuring script to run on chroot"
    sudo cp mnt/root/.bashrc mnt/root/bashrc
    sudo cp ${BASE_DIR}/bashrc mnt/root/.bashrc
fi

# Disable restart prompts
sudo mv mnt/etc/apt/apt.conf.d/99needrestart mnt/etc/apt/apt.conf.d/.99needrestart

sudo chroot mnt