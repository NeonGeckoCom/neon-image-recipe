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

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# Install build dependencies
apt update
apt install -y g++ libboost-dev libgnutls28-dev openssl libtiff5-dev \
 python3-yaml python3-ply python3-jinja2 libglib2.0-dev \
 libssl-dev meson ninja-build pkg-config qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
 cmake libboost-program-options-dev libdrm-dev libexif-dev libpng-dev libegl1-mesa-dev \
 v4l-utils
 # libgstreamer-plugins-base1.0-dev

# Clone and build libcamera
git clone https://github.com/raspberrypi/libcamera.git
cd libcamera || exit 10
meson build --buildtype=release -Dpipelines=raspberrypi -Dipas=raspberrypi -Dv4l2=true -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled
ninja -C build install
cd ..
rm -rf libcamera

# Clone and build libepoxy
git clone https://github.com/anholt/libepoxy.git
cd libepoxy || exit 10
mkdir _build
cd _build || exit 10
meson
ninja
ninja install
cd ../..
rm -rf libepoxy

# Clone and build libcamera-apps
git clone https://github.com/raspberrypi/libcamera-apps.git
cd libcamera-apps || exit 10
mkdir build
cd build || exit 10
cmake .. -DENABLE_DRM=1 -DENABLE_X11=0 -DENABLE_QT=1 -DENABLE_OPENCV=0 -DENABLE_TFLITE=0
make install

echo "Camera dependencies installed"
