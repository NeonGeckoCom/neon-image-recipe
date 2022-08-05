 #!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

# Install gui base dependencies
apt update
apt install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools \
     qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev \
     libkf5plasma-dev libqt5webview5-dev qtmultimedia5-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
     gstreamer1.0-libav qml-module-qtwayland-compositor libqt5multimedia5-plugins qml-module-qtmultimedia plasma-pa xorg \
     qtwayland5 qml-module-qtquick-virtualkeyboard qtvirtualkeyboard-plugin qml-module-qtwebchannel \
     qml-module-qt-labs-folderlistmodel qt5ct qml-module-qtquick-shapes qml-module-qtquick-particles2 \
     qml-module-qtquick-templates2 qml-module-qtquick-xmllistmodel qml-module-qtquick-localstorage \
     qml-module-qmltermwidget qml-module-qttest qml-module-qtlocation qml-module-qtpositioning \
     qml-module-qtgraphicaleffects qml-module-qtqml-models2 kirigami2-dev \
     --no-install-recommends

# Install embedded-shell
git clone https://github.com/OpenVoiceOS/ovos-shell

# Add customized splash screen
cp -f neon_splashscreen.png ovos-shell/application/qml/background.png
cp -f neon_logo.svg ovos-shell/application/icons/ovos-egg.svg

cd ovos-shell || exit 10
cmake .
bash prefix.sh
make ovos-shell
make install ovos-shell || exit 10
cd "${BASE_DIR}" || exit 10
rm -rf ovos-shell

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
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make -j4
make install

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
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
make install

cd "${BASE_DIR}" || exit 10
rm -rf mycroft-gui

# Copy overlay files and enable gui service
cp -r overlay/* /
chmod -R ugo+x /usr/bin

systemctl enable neon-gui

# Fix tmp dir permissions
mkdir -p /tmp/neon
chmod 777 /tmp/neon
