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

build_dir=${1}
cd "${build_dir}" || exit 10

# Re-enable restart prompts
if [ -f mnt/etc/apt/apt.conf.d/.99needrestart ]; then
    sudo mv mnt/etc/apt/apt.conf.d/.99needrestart mnt/etc/apt/apt.conf.d/99needrestart
fi

# Cleanup overridden resolv.conf
sudo rm mnt/etc/resolv.conf
if [ -f mnt/etc/.resolv.conf ]; then
    sudo mv mnt/etc/.resolv.conf mnt/etc/resolv.conf
fi

# Cleanup root bashrc
sudo rm mnt/root/.bashrc
if [ -f mnt/root/bashrc ]; then
    echo "Restoring root .bashrc file"
    sudo mv mnt/root/bashrc mnt/root/.bashrc
fi

# Replace swapfile for build
if [ -f "${build_dir}/swapfile" ]; then
    echo "replacing swapfile"
    sudo mv "${build_dir}/swapfile" mnt/swapfile
fi

#sudo mv mnt/root/bashrc mnt/root/.bashrc
sudo rm -rf mnt/tmp/*
echo "Temporary files removed"
sudo umount mnt/boot/firmware || echo "boot partition not mounted"
sudo umount mnt/run/systemd/resolve || exit 10

# Make squashFS
mksquashfs mnt neon.squashfs -noappend

sudo umount mnt || exit 10
rm -r mnt
sudo parted /dev/loop99 rm 2
sudo parted -a minimal /dev/loop99 mkpart primary ext4 64 2048 && echo "Created Root partition"
sudo dd if=neon.squashfs of=/dev/loop99p2 && echo "Wrote squashFS partition"
sudo parted -a minimal /dev/loop99 mkpart primary ext4 2048 3072 && echo "Created User partition"
sudo losetup -d /dev/loop99
echo "Image unmounted"