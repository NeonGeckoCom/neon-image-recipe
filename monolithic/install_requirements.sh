
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "GITHUB_TOKEN not specified!"
  exit 1
fi

# update base image
sudo apt-get update
sudo apt-get upgrade -y

# install system packages
sudo apt-get install -y  alsa-utils \
     libasound2 libasound2-plugins \
     pulseaudio pulseaudio-utils \
     sox libsox-fmt-all \
     python3-pip network-manager swig libfann-dev gcc

# Ubuntu Server Deps
sudo apt install -y xorg openbox portaudio19-dev

pip install --upgrade pip~=21.1
pip install wheel
pip install "git+https://${GITHUB_TOKEN}@github.com/NeonDaniel/NeonCore@FEAT_PiSupport#egg=neon_core[remote,client,dev]"

# mycroft-gui
git clone https://github.com/mycroftai/mycroft-gui
#bash mycroft-gui/dev_setup.sh
cd mycroft-gui || exit 10
TOP=$( pwd -L )
sudo apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools \
     qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev \
     libkf5plasma-dev libqt5webview5-dev qtmultimedia5-dev

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

echo " "
if [[ ! -f /etc/mycroft/mycroft.conf ]] ; then
    if [[ ! -d /etc/mycroft ]] ; then
        sudo mkdir /etc/mycroft
    fi

cat <<EOF | sudo tee /etc/mycroft/mycroft.conf
{
    "enclosure": {
        "platform": "mycroft_mark_2"
    }
}
EOF

fi

if [[ -f /etc/mycroft/mycroft.conf ]] ; then
    echo "Found an existing Mycroft System Level Configuration at /etc/mycroft/mycroft.conf"
    echo "Please add the following enclosure settings manually to existing configuration to ensure working setup:"
    echo " "
    echo '"enclosure": {'
    echo '     "platform": "mycroft_mark_2"'
    echo '}'
    echo ""
fi
echo "Installation complete!"
echo "To run, invoke:  mycroft-gui-app"

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
