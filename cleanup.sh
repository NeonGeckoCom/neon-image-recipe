#!/bin/bash

BASE_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}" || exit 10

rm -r mnt/tmp/*
sudo umount mnt/run/systemd/resolve
sudo umount mnt
echo "Image unmounted"