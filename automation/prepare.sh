#!/bin/bash
# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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


# Determine Partition Offsets
lines=$(fdisk -l "${image_file}")
IFS=$'\n'
for line in ${lines}; do
    # Check Block Size
    if (grep -q '^Units:' <<< "${line}") ; then
      blk_size=$( echo "${line}" | cut -d ' ' -f 8)
  # Check Partition
    elif (grep -q "^${image_file}" <<< "${line}") ; then
        IFS=$' \t\n'
        parts=(${line})

        if [ -z "${boot_start}" ]; then
            echo "Boot Partition: ${parts[0]}"
            for part in "${parts[@]}"; do
                if [[ ${part} =~ ^[0-9]+$ ]]; then
                    boot_start=${part}
                    break
                fi
            done
        elif [ -z "${root_start}" ]; then
            echo "Root Partition: ${parts[0]}"
            for part in "${parts[@]}"; do
                if [[ ${part} =~ ^[0-9]+$ ]]; then
                    root_start=${part}
                    break
                fi
            done
        else
            echo "Extra partition detected: ${parts[*]}"
        fi
    fi
done
boot=$((boot_start*blk_size))
root=$((root_start*blk_size))
echo "boot=${boot}"
echo "root=${root}"

echo "Copying Boot Overlay Files"
# RaspiOS Lite=4194304
# Ubuntu Server=1048576
# Apertis=64000512
sudo mount -o loop,offset=${boot} "${image_file}" boot || exit 10
if [[ "${image_file}" == *"ubuntu_22_04"* ]]; then
    echo "Applying Ubuntu 20.04 Boot Overlay"
    sudo cp -r "${recipe_dir}/00_boot_overlay/ubuntu_22_04/"* boot/
elif [[ "${image_file}" == *"ubuntu_20_04"* ]]; then
    echo "Applying Ubuntu 22.04 Boot Overlay"
    sudo cp -r "${recipe_dir}/00_boot_overlay/ubuntu_20_04/"* boot/
elif [[ "${image_file}" == *"debian"* ]]; then
    echo "Applying Debian Bullseye Boot Overlay"
    sudo cp -r "${recipe_dir}/00_boot_overlay/debian/"* boot/
else
    echo "No Overlay for image: ${image_file}"
fi
sleep 1  # Avoid busy target issues
sudo umount boot
rm -r boot
echo "Boot Files Configured"

echo "Mounting Image FS"
# RaspiOS Lite=272629760
# Ubuntu Server=269484032
# Apertis=256000512
sudo mount -o loop,offset=${root} "${image_file}" mnt || exit 10
sudo mkdir -p mnt/run/systemd/resolve
sudo mount --bind /run/systemd/resolve mnt/run/systemd/resolve  && echo "Mounted resolve directory from host" || exit 10

echo "Writing Build Info to Image"
sudo mkdir -p mnt/opt/neon
sudo mv "${build_dir}/meta.json" mnt/opt/neon/build_info.json || echo "No meta.json for image"

if [ -d "${build_dir}/overlay" ]; then
    echo "Copying build-time overlay files"
    cp -r ${build_dir}/overlay/* mnt
fi

echo "Copying Image scripts"
cp -r "${recipe_dir}/01_core_configuration" mnt/tmp/
cp -r "${recipe_dir}/02_network_manager" mnt/tmp/
cp -r "${recipe_dir}/03_sj201" mnt/tmp/
cp -r "${recipe_dir}/04_embedded_shell" mnt/tmp/
cp -r "${recipe_dir}/05_neon_core" mnt/tmp/
cp -r "${recipe_dir}/06_dashboard" mnt/tmp/
cp -r "${recipe_dir}/07_camera" mnt/tmp/
cp -r "${recipe_dir}/08_splash_screen" mnt/tmp/

# Copy interactive script into base image
cp "${BASE_DIR}/run_scripts.sh" mnt/tmp

# Copy variables into base image
echo "export CORE_REF=${CORE_REF:-dev}" > mnt/tmp/vars.sh
echo "export MAKE_THREADS=${MAKE_THREADS:-4}" >> mnt/tmp/vars.sh

# Configure bashrc so script runs on login (chroot)
if [ "${3}" == "-y" ]; then
    echo "Configuring script to run on chroot"
    sudo cp mnt/root/.bashrc mnt/root/bashrc
    sudo cp "${BASE_DIR}/bashrc" mnt/root/.bashrc
fi

# Disable restart prompts
if [ -f mnt/etc/apt/apt.conf.d/99needrestart ]; then
    sudo mv mnt/etc/apt/apt.conf.d/99needrestart mnt/etc/apt/apt.conf.d/.99needrestart
fi

if [ -f mnt/etc/resolv.conf ]; then
    sudo mv mnt/etc/resolv.conf mnt/etc/.resolv.conf
fi

sudo cp "${BASE_DIR}/resolv.conf" mnt/etc/resolv.conf

sudo chroot mnt