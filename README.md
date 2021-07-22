# neon-image-recipe
how to make a neon image from scratch

- monolithic -> old style, single script launches everything

# Usage
Installation should be performed by the user `neon`.

```bash
git clone https://github.com/NeonGeckoCom/neon-image-recipe
cd neon-image-recipe/monolithic
sudo bash ./desktop_setup.sh
sudo reboot
# On Reboot, you may need to log out and log back into the Openbox DE
sudo -E bash ./install_requirements.sh
sudo bash ./setup_system.sh
sudo bash ./host_configuration.sh
sudo reboot now
```
