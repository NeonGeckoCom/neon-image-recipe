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

# Clone the latest image recipe
# TODO: Update branch
git clone https://github.com/neongeckocom/neon-image-recipe -b FEAT_CoreUpdateVersioning && echo "Downloaded Image Tools"

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

rm -rf neon-image-recipe && echo "Cleaned up recipe patches"