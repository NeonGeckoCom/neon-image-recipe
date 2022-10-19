#!/home/neon/venv/bin/python
from neon_utils.process_utils import start_systemd_service
from neon_core.skills.__main__ import main

start_systemd_service(main)
