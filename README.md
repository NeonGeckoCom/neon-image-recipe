# neon-image-recipe
how to make a neon image from scratch

- monolithic -> old style, single script launches everything


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

# Usage

```bash
git clone https://github.com/NeonGeckoCom/neon-image-recipe
cd neon-image-recipe
sudo bash ./install_requirements.sh
sudo bash ./setup_system.sh
sudo bash ./host_configuration.sh
sudo reboot now
```
