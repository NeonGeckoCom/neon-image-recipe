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

dist=$(grep "^Distributor ID:" <<<"$(lsb_release -a)" | cut -d':' -f 2 | tr -d '[:space:]')

if [ "${dist}" == 'Ubuntu' ]; then
    add-apt-repository -y ppa:deadsnakes/ppa
    apt update
    apt install -y python3.7-dev python3.7-venv
fi

# install system packages
apt install -y curl
curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | apt-key add - 2> /dev/null && \
echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" | tee /etc/apt/sources.list.d/mycroft-desktop.list
apt update
apt install -y sox gcc libfann-dev swig libssl-dev portaudio19-dev git libpulse-dev mimic \
    espeak-ng g++ wireless-tools plasma-nm unzip ffmpeg make || exit 1

# Cleanup apt caches
rm -rf /var/cache/apt/archives/*

# Configure venv for deepspeech compat.
python3.7 -m venv "/home/neon/venv" || exit 10
. /home/neon/venv/bin/activate
pip install --upgrade pip wheel


# Copy overlay files (default configuration)
cd "${BASE_DIR}" || exit 10
cp -rf overlay/* / || exit 2
cd /home/neon || exit 2

# Install core and skills
pip install "git+https://github.com/neongeckocom/neoncore@${CORE_REF:-dev}#egg=neon_core[core_modules,skills_required,skills_essential,skills_default,skills_extended,pi,local,remote]" || exit 11
echo "Core Installed"
neon-install-default-skills && echo "Default git skills installed" || exit 2

# Clean pip caches
rm -rf /root/.cache/pip

# Download model files
mkdir -p /home/neon/.local/share/neon
wget -O /home/neon/.local/share/neon/vosk-model-small-en-us-0.15.zip https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
cd /home/neon/.local/share/neon || exit 10
unzip vosk-model-small-en-us-0.15.zip
rm vosk-model-small-en-us-0.15.zip

export XDG_CONFIG_HOME="/home/neon/.config"
export XDG_DATA_HOME="/home/neon/.local/share"
export XDG_CACHE_HOME="/home/neon/.cache"

# Init TTS model
neon-audio init-plugin || echo "Failed to init TTS"
# Init STT model
neon-speech init-plugin || echo "Failed to init STT"

ln -s /home/neon/.local/state/neon /home/neon/logs
rm /home/neon/.local/state/neon/.keep
# Fix home directory permissions
chown -R neon:neon /home/neon

# Ensure executable
chmod +x /opt/neon/*.sh
chmod +x /usr/sbin/*
chmod +x /usr/bin/*
chmod +x /usr/libexec/*

# Enable services
systemctl enable neon.service
systemctl enable neon-admin-enclosure.service
systemctl enable neon-audio.service
systemctl enable neon-bus.service
systemctl enable neon-enclosure.service
systemctl enable neon-gui.service
systemctl enable neon-logs.service
systemctl enable neon-skills.service
systemctl enable neon-speech.service

# Disable wifi setup service
systemctl disable wifi-setup

# Setup Completed
echo "Setup Complete"
