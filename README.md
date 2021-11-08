# neon-image-recipe
Make a Pi image from scratch. It is recommended to disable automatic updates during this process:

```shell
sudo dpkg-reconfigure unattended-upgrades
```
- [Network Manager](#base_network_manager) - Configures networking to allow for wifi configuration via
  [wifi-connect](https://github.com/balena-os/wifi-connect).
- [Ubuntu Server](#base_ubuntu_server) - Configures a desktop environment, user account, and other system setting overrides.
- [SJ201 Support](#base_mark_2) - Installs and configures drivers and scripts to run the SJ-201 HAT.
- [Neon Core](#base_neon_core) - Installs Neon Core with dependencies.
- monolithic -> old style, single script launches everything

## base_network_manager
Adds Balena wifi-connect to enable a portal for connecting the Pi device to a wifi network. After running the setup script,
the Pi will restart and be ready to configure with SSID `Neon`.

```shell
cd base_network_manager
bash ./setup_wifi_connect.sh
```

## base_ubuntu_server
For Ubuntu Server base images, the included scripts install the openbox DE, add a `neon` user with default `neon` password, 
and configure the system to auto-login and disable sleep. `cleanup.sh` removes the `ubuntu` user, expires the `neon` user 
password, and schedules a device restart.

```shell
cd base_ubuntu_server
bash ./desktop_setup
# Reboot system and reconnect as 'neon' user
sudo cp /home/ubuntu/neon-image-recipe/base_ubuntu_server/cleanup.sh /tmp/cleanup.sh
bash /tmp/cleanup.sh
```

## base_mark_2
For SJ201 board support, the included script will build/install drivers, add required overlays, install required system 
packages, and add a systemd service to flash the SJ201 chip on boot. This will modify pulseaudio and potentially overwrite 
any previous settings.

>*Note:* Running this scripts grants GPIO permissions to the `gpio` group. Any user that interfaces with the SJ201 board
> should be a member of the `gpio` group. Group permissions are not modified by this script

```shell
cd base_mark_2
bash ./install_xmos_drivers.sh
```

## base_neon_core
Installs the base Neon core and dependencies. Installation should be performed by the user `neon`.
```bash
git clone https://github.com/NeonGeckoCom/neon-image-recipe
cd neon-image-recipe/monolithic
bash ./install_requirements.sh
bash ./setup_system.sh
#sudo bash ./host_configuration.sh
sudo reboot now
```
