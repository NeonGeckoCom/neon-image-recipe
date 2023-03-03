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

################################################################################
# Dynamic script to apply patches to existing Neon images. By default, Neon OS
# installations will run this script to ensure images have all expected systemd
# services, apt packages, and system configurations.
################################################################################

if [ -d neon-image-recipe ]; then
  rm -rf neon-image-recipe && echo "Removed old cloned recipe repo"
fi

branch=${1:-dev}

# Clone the latest image recipe
git clone https://github.com/neongeckocom/neon-image-recipe -b "${branch}" && echo "Downloaded Image Tools from ${branch}"

# Check for updater service
if [ ! -f /usr/lib/systemd/system/neon-updater.service ]; then
  echo "Adding Updater Service"
  bash neon-image-recipe/patches/add_updater_service.sh
# Check for updater version handling patch
elif [ ! -f /etc/neon/versions.conf ]; then
  echo "Updating Update Version Handling"
  bash neon-image-recipe/patches/patch_updater_version_handling.sh
fi

# Check for reset service
if [ ! -f /usr/lib/systemd/system/neon-reset.service ]; then
  echo "Adding Reset Service"
  bash neon-image-recipe/patches/add_reset_service.sh
fi

# Check for USB Automount
if [ ! -f /etc/auto.usb ]; then
  echo "Adding autofs"
  bash neon-image-recipe/patches/add_autofs.sh
fi

# Check for old poweroff service
if ! grep -q "Conflicts=reboot.target" /usr/lib/systemd/system/poweroff.service; then
  echo "Patching Reboot"
  bash neon-image-recipe/patches/patch_poweroff_service.sh
fi

# Check for old pulse system.pa
if grep -q "load-module module-combine-sink sink_name=OpenVoiceOS" /etc/pulse/system.pa; then
  echo "Patching old SJ201 system.pa file"
  bash neon-image-recipe/patches/patch_sj201_pulse_config.sh
fi

# Check for old neon services
if ! grep -q "TimeoutStopSec=60" /usr/lib/systemd/system/neon-speech.service; then
  echo "Patching Service Timeout"
  bash neon-image-recipe/patches/patch_service_timeout.sh
fi

# Check for missing theme files
if [ -f /home/neon/.local/share/OVOS/ColorSchemes/neon_scheme.json ]; then
  echo "Patching theme files"
  bash neon-image-recipe/patches/patch_default_theme.sh
fi

# Add Homeassistant shortcut
. /home/neon/venv/bin/activate
pip show ovos-phal-plugin-homeassistant
if [ "${?}" == "0" ]; then
  echo "Homeassistant plugin installed"
  if [ ! -f /home/neon/.local/share/applications/ovos-phal-homeassistant.desktop ]; then
    bash neon-image-recipe/patches/add_homeassistant_shortcut.sh
  fi
fi

# Check for Precise
if [ ! -f /home/neon/.local/share/neon/hey-mycroft.pb ]; then
  echo "Downloading Precise"
  bash neon-image-recipe/patches/get_precise_binary.sh
fi

# Remove web_cache config
if [ -f /home/neon/.config/neon/web_cache.json ]; then
  echo "Removing web_cache.json"
  rm -f /home/neon/.config/neon/web_cache.json
fi

rm -rf neon-image-recipe && echo "Cleaned up recipe patches"