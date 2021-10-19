# neon-image-recipe
how to make a neon image from scratch

- monolithic -> old style, single script launches everything

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
