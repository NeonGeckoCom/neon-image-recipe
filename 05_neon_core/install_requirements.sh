#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# install system packages
add-apt-repository -y ppa:deadsnakes/ppa
apt install -y curl
curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | apt-key add - 2> /dev/null && \
echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" | tee /etc/apt/sources.list.d/mycroft-desktop.list
apt update
apt install -y sox gcc libfann-dev swig libssl-dev portaudio19-dev git libpulse-dev python3.7-dev python3.7-venv mimic git-lfs espeak-ng || exit 1

# Configure venv for deepspeech compat.
python3.7 -m venv "/home/neon/venv" || exit 10
. /home/neon/venv/bin/activate
pip install --upgrade pip wheel


# Copy overlay files (default configuration)
cd "${BASE_DIR}" || exit 10
cp -rf overlay/* / || exit 2
cd /home/neon

# Install core
pip install git+https://github.com/neongeckocom/neoncore@FEAT_PiImageCompat#egg=neon_core[core_modules,skills_required,skills_essential,skills_default,skills_extended,pi,local]

# Download model files
mkdir -p /home/neon/.local/share/neon
wget -O /home/neon/.local/share/neon/deepspeech-0.9.3-models.scorer https://github.com/mozilla/DeepSpeech/releases/download/v0.9.3/deepspeech-0.9.3-models.scorer
wget -O /home/neon/.local/share/neon/deepspeech-0.9.3-models.tflite https://github.com/mozilla/DeepSpeech/releases/download/v0.9.3/deepspeech-0.9.3-models.tflite

#mkdir -p /home/neon/.cache/huggingface/hub
#git clone https://huggingface.co/neongeckocom/tts-vits-ljspeech-en /tmp/tts_en
#cd /tmp/tts_en
#tag=$(git describe)
#model_commit=$(git rev-parse HEAD)
#mv /tmp/tts_en /home/neon/.cache/huggingface/hub/neongeckocom--tts-vits-ljspeech-en.${tag}.${model_commit}
# TODO: Also looking for .../hub/models--neongeckocom--tts-vits-ljspeech-en/refs/${tag}
mkdir /home/neon/logs

# Fix home directory permissions
chown -R neon:neon /home/neon

# Ensure executable
chmod +x /opt/neon/*.sh
chmod +x /usr/sbin/*
chmod +x /usr/bin/*

# Enable services
systemctl enable neon
systemctl enable neon_audio
systemctl enable neon_bus
systemctl enable neon_firstboot
systemctl enable neon_gui
systemctl enable neon_skills
systemctl enable neon_speech

# Disable wifi service and let the skill handle it
#systemctl disable wifi-setup.service
echo "neon ALL = (ALL) NOPASSWD: /usr/local/sbin/wifi-connect" >> /etc/sudoers

# Setup Completed
echo "Setup Complete"
