#!/bin/bash
# This needs to run as root

# Enable Driver Overlay
dtoverlay xvf3510

# Flash xmos firmware
xvf3510-flash --direct /usr/lib/firmware/xvf3510/app_xvf3510_int_spi_boot_v4_1_0.bin
# Init TI Amp
sj201 init-ti-amp
# Reset LEDs
sj201 reset-led green
# Reset fan speed
sj201 set-fan-speed 30
