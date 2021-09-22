#!/bin/bash
# This needs to run as root
sudo xvf3510-flash --direct /usr/lib/firmware/xvf3510/app_xvf3510_int_spi_boot_v4_1_0.bin
sudo tas5806-init