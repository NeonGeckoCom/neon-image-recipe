#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# Install gui base dependencies
sudo apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools \
     qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev \
     libkf5plasma-dev libqt5webview5-dev qtmultimedia5-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
     qml-module-qtwayland-compositor libqt5multimedia5-plugins qml-module-qtmultimedia plasma-pa --no-install-recommends

# Install embedded-shell
git clone https://github.com/OpenVoiceOS/mycroft-embedded-shell
cd mycroft-embedded-shell || exit 10
cmake .
bash prefix.sh
make mycroft-embedded-shell
sudo make install mycroft-embedded-shell
cd "${BASE_DIR}" || exit 10
rm -rf mycroft-embedded-shell

# Install GUI
git clone https://github.com/mycroftai/mycroft-gui
#bash mycroft-gui/dev_setup.sh
cd mycroft-gui || exit 10
TOP=$( pwd -L )


echo "Building Mycroft GUI"
if [[ ! -d build-testing ]] ; then
  mkdir build-testing
fi
cd build-testing || exit 10
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make -j4
sudo make install

echo "Installing Lottie-QML"
cd "$TOP" || exit 10
if [[ ! -d lottie-qml ]] ; then
    git clone https://github.com/kbroulik/lottie-qml
    cd lottie-qml || exit 10
    mkdir build
else
    cd lottie-qml || exit 10
    git pull
fi

cd build || exit 10
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install

cd "${BASE_DIR}" || exit 10
rm -rf mycroft-gui

# Copy overlay files and enable gui service
sudo cp -r overlay/* /
sudo chmod -R ugo+x /usr/bin
