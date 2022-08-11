#!/bin/bash

start=$(date +%s)

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir ${BASE_DIR}/build
cd "${BASE_DIR}/build" || exit 10

if [ ! -f ubuntu_22_04.img.xz ]; then
    echo "Downloading Base Ubuntu 22.04 Image"
    wget https://2222.us/app/files/neon_images/pi/ubuntu_22_04.img.xz
fi

xz --decompress ubuntu_22_04.img.xz -v --keep

cd ${BASE_DIR} || exit 10
bash prepare.sh ${BASE_DIR}/build/ubuntu_22_04.img -y
bash cleanup.sh
mkdir outputs

cd ${BASE_DIR} || exit 10
meta=$(python get_metadata.py)
echo ${meta}>outputs/${start}_meta.json
filename="${start}_neon.img"
sudo ./pishrink.sh build/ubuntu_22_04.img "outputs/${filename}"
sudo rm build/ubuntu_22_04.img
sudo chown ${USER}:${USER} "outputs/${filename}"
xz --compress "outputs/${filename}" -v --keep

runtime=$(($(date +%s)-${start}))
echo "Image created in ${runtime}s"
