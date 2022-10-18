from neon_utils.process_utils import start_systemd_service
from neon_messagebus.service.__main__ import main

start_systemd_service(main)
