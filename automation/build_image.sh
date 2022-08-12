#!/bin/bash

# Set to exit on error
set -Ee

# Check if a sudo password should be cached
sudo -K
sudo -n ls || read -s -p "Enter sudo password for $(whoami): " passwd
# TODO: Validate password

start=$(date +%s)

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_dir=${BUILD_DIR:-"${BASE_DIR}/build"}
output_dir=${OUTPUT_DIR:-"${BASE_DIR}/outputs"}

export CORE_REF="FEAT_PiImageCompat"

if [ ! -d "${build_dir}" ]; then
    echo "Creating 'build' directory"
    mkdir -p "${build_dir}"
fi
cd "${build_dir}" || exit 10

if [ ! -f ubuntu_22_04.img.xz ]; then
    echo "Downloading Base Ubuntu 22.04 Image"
    wget https://2222.us/app/files/neon_images/pi/ubuntu_22_04.img.xz
fi

xz --decompress ubuntu_22_04.img.xz -v --keep && echo "Decompressed Image"

# Get Build info
cd "${BASE_DIR}" || exit 10
meta="$(python get_metadata.py)"
echo ${meta}>"${build_dir}/meta.json"
echo "Got Build Info"

# Cache sudo password for setup
echo "${passwd}" | sudo -S ls
bash prepare.sh "${build_dir}/ubuntu_22_04.img" "${build_dir}" -y

# Cache sudo password for cleanup
echo "${passwd}" | sudo -S ls
bash cleanup.sh "${build_dir}"

if [ ! -d "${output_dir}" ]; then
    echo "Creating 'outputs' directory"
    mkdir "${output_dir}"
fi

cd "${BASE_DIR}" || exit 10
echo "${meta}">"${output_dir}/${start}_meta.json"
filename="${start}_neon.img"
sudo ./pishrink.sh "${build_dir}/ubuntu_22_04.img" "${output_dir}/${filename}" || echo "already minimized"
sudo rm "${build_dir}/ubuntu_22_04.img"
sudo chown ${USER}:${USER} "${output_dir}/${filename}"
xz --compress "${output_dir}/${filename}" -v

runtime=$(($(($(date +%s)-${start}))/60))
echo "Image created in ${runtime} minutes"
