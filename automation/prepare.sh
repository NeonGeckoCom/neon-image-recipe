#!/bin/bash

# Set to exit on error
set -Ee

image_file=${1}
build_dir=${2}

if [ -z "${image_file}" ]; then
    echo "No file specified to mount"
    exit 2
fi

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
recipe_dir="${BASE_DIR}/.."
cd "${build_dir}" || exit 10

mkdir boot
mkdir mnt

echo "Copying Boot Overlay Files"
sudo mount -o loop,offset=1048576 "${image_file}" boot || exit 10
sudo cp -r ${recipe_dir}/00_boot_overlay/ubuntu_22_04/* boot/
sleep 1  # Avoid busy target issues
sudo umount boot
rm -r boot
echo "Boot Files Configured"

echo "Mounting Image FS"
sudo mount -o loop,offset=269484032 "${image_file}" mnt || exit 10
sudo mkdir -p mnt/run/systemd/resolve
sudo mount --bind /run/systemd/resolve mnt/run/systemd/resolve  && echo "Mounted resolve directory from host" || exit 10

echo "Writing Build Info to Image"
sudo mkdir -p mnt/opt/neon
sudo mv "${build_dir}/meta.json" mnt/opt/neon/build_info.json

echo "Copying Image scripts"
cp -r ${recipe_dir}/01_core_configuration mnt/tmp/
cp -r ${recipe_dir}/02_network_manager mnt/tmp/
cp -r ${recipe_dir}/03_sj201 mnt/tmp/
cp -r ${recipe_dir}/04_embedded_shell mnt/tmp/
cp -r ${recipe_dir}/05_neon_core mnt/tmp/

# Copy interactive script into base image
cp "${BASE_DIR}/run_scripts.sh" mnt/tmp

# Copy variables into base image
echo "export CORE_REF=${CORE_REF:-dev}" > mnt/tmp/vars.sh

# Configure bashrc so script runs on login (chroot)
if [ "${3}" == "-y" ]; then
    echo "Configuring script to run on chroot"
    sudo cp mnt/root/.bashrc mnt/root/bashrc
    sudo cp ${BASE_DIR}/bashrc mnt/root/.bashrc
fi

# Disable restart prompts
sudo mv mnt/etc/apt/apt.conf.d/99needrestart mnt/etc/apt/apt.conf.d/.99needrestart

sudo chroot mnt