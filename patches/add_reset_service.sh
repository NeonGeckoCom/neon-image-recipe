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
# One-time script to configure the Neon update service and run an update on an
# existing installation. Enables the `neon-updater` service and performs the
# first update to ensure the skill and plugin are available for future updates.
################################################################################

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

git clone https://github.com/neongeckocom/neon-image-recipe && echo "Downloaded Image Tools"
sudo bash neon-image-recipe/11_factory_reset/configure_reset.sh && echo "Configured Reset Service"
sudo /home/neon/venv/bin/python "${BASE_DIR}/neon-image-recipe/patches/patch_core_config_reset.py" && echo "Updated Core Configuration"

sudo mkdir -p /opt/neon/backup
sudo cp -r neon-image-recipe/05_neon_core/overlay/home/neon/.config /opt/neon/backup/.config && echo "Got default config backup"
sudo cp -r neon-image-recipe/05_neon_core/overlay/home/neon/.local /opt/neon/backup/.local && echo "Got default data backup"
if [ -d /home/neon/.cache/neon/venv_backup ]; then
  sudo cp -r /home/neon/.cache/neon/venv_backup /opt/neon/backup/venv && echo "Backup venv_backup for factory reset"
else
  sudo cp -r /home/neon/venv /opt/neon/backup/venv && echo "Backup venv for factory reset"
fi
sudo rm -rf neon-image-recipe
sudo systemctl daemon-reload
echo "Reset service enabled"
