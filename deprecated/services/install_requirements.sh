# update base image
sudo apt-get update
sudo apt-get upgrade

# install system packages
sudo apt-get install -y  alsa-utils \
        libasound2 libasound2-plugins \
        pulseaudio pulseaudio-utils \
        sox libsox-fmt-all \
        python3-pip network-manager

# TODO neon specific requirements

# TODO mycroft-gui

