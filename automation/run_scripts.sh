#!/bin/bash

cd /tmp || exit 10

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