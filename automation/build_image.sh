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

start=$(date +%s)

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_dir=${BUILD_DIR:-"${BASE_DIR}/build"}
output_dir=${OUTPUT_DIR:-"${BASE_DIR}/outputs"}
base_image=${BASE_IMAGE:-"ubuntu_22_04"}
echo "build_dir=${build_dir}"
echo "output_dir=${output_dir}"
echo "base_image=${base_image}"

export CORE_REF=${CORE_REF:-"dev"}

if [ ! -d "${build_dir}" ]; then
    echo "Creating 'build' directory"
    mkdir -p "${build_dir}"
fi
cd "${build_dir}" || exit 10

base_image_compressed="${build_dir}/${base_image}.img.xz"
# debian_bullseye.img.xz, ubuntu_22_04.img.xz
if [ ! -f "${base_image_compressed}" ]; then
    echo "Downloading Base Image ${base_image}"
    wget -q "https://2222.us/app/files/neon_images/pi/${base_image}.img.xz"
fi

# Decompress xz image archive
if [[ "${base_image_compressed}" == *.xz ]]; then
    xz --decompress -T0 "${base_image_compressed}" -v --keep && echo "Decompressed Image"
    base_image_file=${base_image_compressed%.*}
else
    base_image_file=${base_image_compressed}
fi

# Get Build info
cd "${BASE_DIR}" || exit 10
meta="$(python get_metadata.py)"
echo "${meta}">"${build_dir}/meta.json"
echo "Got Build Info"

# Apply any runtime overlay files
if [ -d "${output_dir}/overlay" ]; then
    echo "Copying Runtime Overlay Files"
    cp -r "${output_dir}/overlay" "${build_dir}/overlay"
fi


# Cache sudo password for setup
#echo "${passwd}" | sudo -S ls
bash prepare.sh "${base_image_file}" "${build_dir}" -y

# Cache sudo password for cleanup
#echo "${passwd}" | sudo -S ls
bash cleanup.sh "${build_dir}"

if [ ! -d "${output_dir}" ]; then
    echo "Creating 'output' directory"
    mkdir "${output_dir}"
fi

cd "${BASE_DIR}" || exit 10
#echo "${meta}">"${output_dir}/${start}_meta.json" && echo "Wrote Metadata"

# Rename completed image file
filename="${start}_neon.img"
echo "Writing output file to: ${build_dir}/${filename}"
mv "${build_dir}/${base_image}.img" "${build_dir}/${filename}"

# Compress image and move to output directory
echo "Compressing output file. This may take several minutes to hours..."
compress_start=$(date +%s)
bash pishrink.sh -sZa "${build_dir}/${filename}" || xz --compress -T0 "${build_dir}/${filename}" -v
compress_time=$(($(($(date +%s)-compress_start))/60))
echo "Image compressed in ${compress_time} minutes"
mv "${build_dir}/${filename}.xz" "${output_dir}/${filename}.xz"
echo "Image saved to ${output_dir}/${filename}.xz"
runtime=$(($(($(date +%s)-start))/60))
echo "Image created in ${runtime} minutes"
