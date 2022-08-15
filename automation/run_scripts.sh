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

# Set to exit on error
set -Ee

cd /tmp || exit 10
source vars.sh

print_opts() {
    clear
    echo ""
    echo "------------------"
    echo "Neon Image Creator"
    echo "------------------"
    echo "1. Core Configuration"
    echo "2. Network Manager"
    echo "3. SJ201 (Mark 2)"
    echo "4. Embedded Shell + GUI"
    echo "5. Neon Core"
    echo "6. Exit"
}

get_choice() {
    read -p "Select Option " opt
    case ${opt} in
        1) bash 01_core_configuration/configure_ubuntu.sh;;
        2) bash 02_network_manager/setup_wifi_connect.sh;;
        3) bash 03_sj201/setup_sj201.sh;;
        4) bash 04_embedded_shell/install_gui_shell.sh;;
        5) bash 05_neon_core/install_requirements.sh;;
        6) exit 0;;
        *) ;;
    esac
}

if [ ${1} == "all" ]; then
    bash 01_core_configuration/configure_ubuntu.sh
    bash 02_network_manager/setup_wifi_connect.sh
    bash 03_sj201/setup_sj201.sh
    bash 04_embedded_shell/install_gui_shell.sh
    bash 05_neon_core/install_requirements.sh
    exit 0
fi

while true; do
    print_opts
    get_choice
done