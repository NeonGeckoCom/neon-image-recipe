#!/bin/bash

image_file=${1}
if [ -z ${image_file} ]; then
    echo "No file specified to mount"
fi

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

mkdir boot
mkdir mnt

echo "Copying Boot Overlay Files"
sudo mount -o loop,offset=1048576 ${image_file} boot || exit 10
sudo cp -r 00_boot_overlay/ubuntu_22_04/* boot/
sudo umount boot
echo "Boot Files Configured"

echo "Mounting Image FS"
sudo mount -o loop,offset=269484032 ${image_file} mnt || exit 10
sudo mkdir -p mnt/run/systemd/resolve
sudo mount --bind /run/systemd/resolve mnt/run/systemd/resolve  && echo "Mounted resolve directory from host" || exit 10

echo "Copying Image scripts"
cp -r 01_core_configuration mnt/tmp/
cp -r 02_network_manager mnt/tmp/
cp -r 03_sj201 mnt/tmp/
cp -r 04_embedded_shell mnt/tmp/
cp -r 05_neon_core mnt/tmp/

echo "Perform any desired setup and then run 'cleanup.sh'"
sudo chroot mnt