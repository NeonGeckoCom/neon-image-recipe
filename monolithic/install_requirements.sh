# update base image
sudo apt-get update
sudo apt-get upgrade

# install system packages
sudo apt-get install -y  alsa-utils \
        libasound2 libasound2-plugins \
        pulseaudio pulseaudio-utils \
        sox libsox-fmt-all \
        python3-pip network-manager swig libfann-dev gcc

pip install --upgrade pip~=21.1
pip install wheel
pip install "git+https://${GITHUB_TOKEN}@github.com/NeonDaniel/NeonCore@FEAT_PiSupport#egg=neon_core[remote,client,dev]"

# mycroft-gui
git clone https://github.com/mycroftai/mycroft-gui
bash mycroft-gui/dev_setup.sh
rm -rf mycroft-gui
sudo apt-get install libqt5multimedia5-plugins qml-module-qtmultimedia

# Export setup variables
export devMode="false"
export autoStart="true"
export autoUpdate="false"
export installServer="false"
export sttModule="google_cloud_streaming"
export ttsModule="amazon"
export raspberryPi="true"
neon-config-import

# Install Default Skills
neon-install-default-skills

# Setup Completed
echo "Setup Complete"
exit 0
