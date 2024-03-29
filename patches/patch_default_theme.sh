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
# One-time script to patch the default Neon theme
################################################################################


rm /home/neon/.local/share/OVOS/ColorSchemes/neon_scheme.json
cp neon-image-recipe/04_embedded_shell/overlay/home/neon/.config/OpenVoiceOS/OvosShell.conf /home/neon/.config/OpenVoiceOS/OvosShell.conf
cp neon-image-recipe/04_embedded_shell/overlay/home/neon/.local/share/OVOS/ColorSchemes/*.json /home/neon/.local/share/OVOS/ColorSchemes/
cp neon-image-recipe/04_embedded_shell/overlay/etc/xdg/OvosTheme /etc/xdg/OvosTheme
echo "Added new themes"

# Remove extra themes to clean up customization menu
rm /usr/share/OVOS/ColorSchemes/manjaro_scheme.json
rm /usr/share/OVOS/ColorSchemes/ruby_scheme.json
rm /usr/share/OVOS/ColorSchemes/slate_scheme.json
rm /usr/share/OVOS/ColorSchemes/sunset_scheme.json
echo "Removed default themes"

echo "Neon Themes Updated"