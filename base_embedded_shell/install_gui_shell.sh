#!/bin/bash

sudo apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools \
     qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev \
     libkf5plasma-dev libqt5webview5-dev qtmultimedia5-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
     qml-module-qtwayland-compositor
git clone https://github.com/OpenVoiceOS/mycroft-embedded-shell
cmake mycroft-embedded-shell
bash mycroft-embedded-shell/prefix.sh
make mycroft-embedded-shell
make install mycroft-embedded-shell
rm -rf mycroft-embedded-shell

# Install GUI

sudo cp -r overlay/* /
sudo systemctl enable mycroft-gui.service