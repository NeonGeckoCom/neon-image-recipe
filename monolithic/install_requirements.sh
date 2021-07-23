
export GITHUB_TOKEN=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

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
     python3-pip python3-venv network-manager swig libfann-dev gcc mpg123 wireless-tools

# This will break networking! (Even upon re-installing apt package)
#sudo apt remove -y python3-yaml
python3 -m venv "/home/neon/venv"
. /home/neon/venv/bin/activate
pip install --upgrade pip~=21.1
pip install wheel
# TODO: Install from default branch and resolve PyYAML errors
pip install "git+https://${GITHUB_TOKEN}@github.com/NeonDaniel/NeonCore@FEAT_PiSupport#egg=neon_core[pi,dev]"

# Install mimic
sudo apt install -y curl
curl https://forslund.github.io/mycroft-desktop-repo/mycroft-desktop.gpg.key | sudo apt-key add - 2> /dev/null && echo "deb http://forslund.github.io/mycroft-desktop-repo bionic main" | sudo tee /etc/apt/sources.list.d/mycroft-desktop.list
sudo apt-get update
sudo apt install -y mimic

# mycroft-gui
git clone https://github.com/mycroftai/mycroft-gui
#bash mycroft-gui/dev_setup.sh
cd mycroft-gui || exit 10
TOP=$( pwd -L )
sudo apt-get install -y git-core g++ cmake extra-cmake-modules gettext pkg-config qml-module-qtwebengine pkg-kde-tools \
     qtbase5-dev qtdeclarative5-dev libkf5kio-dev libqt5websockets5-dev libkf5i18n-dev libkf5notifications-dev \
     libkf5plasma-dev libqt5webview5-dev qtmultimedia5-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav

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

rm -rf mycroft-gui

# Install extra GUI dependencies not in dev_setup.sh
sudo apt-get install -y libqt5multimedia5-plugins qml-module-qtmultimedia

# Export setup variables
export devMode="false"
export autoStart="true"
export autoUpdate="false"
export installServer="false"
export sttModule="google_cloud_streaming"
export ttsModule="neon_tts_mimic"
export raspberryPi="true"
export skillRepo="https://raw.githubusercontent.com/NeonGeckoCom/neon-skills-submodules/dev/.utilities/DEFAULT-SKILLS-PI"

# TODO: Remove patched skill utils version
pip install --upgrade --pre neon-utils

neon-config-import
#neon-install-default-skills

## Move neon data from root to local user home directory and fix permissions
#sudo mv /root/.local/share/neon /home/neon/.local/share/
sudo chown neon:neon -R /home/neon/.local/share

# Setup Completed
echo "Setup Complete"
exit 0
