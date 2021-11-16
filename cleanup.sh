#!/bin/bash
BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}"/.. || exit 10
sudo rm -r "${BASE_DIR}" || exit 2
sudo rm /etc/NetworkManager/system-connections/* || exit 2
# TODO: Enable resize partition on next boot DM
sudo shutdown
history -c