# neon-image-recipe
how to make a neon image from scratch

- monolithic -> old style, single script launches everything

## base_mark_2
For SJ201 board support, the included script will build/install drivers, add required overlays, install required system 
packages, and add a systemd service to flash the SJ201 chip on boot. This will modify pulseaudio and potentially overwrite 
any previous settings.

```shell
cd base_mark_2
bash ./install_xmos_drivers.sh
```

# Usage

```bash
git clone https://github.com/NeonGeckoCom/neon-image-recipe
cd neon-image-recipe
sudo bash ./install_requirements.sh
sudo bash ./setup_system.sh
sudo bash ./host_configuration.sh
sudo reboot now
```
