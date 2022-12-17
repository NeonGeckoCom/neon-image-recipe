#!/home/neon/venv/bin/python
try:
    from neon_audio.service import NeonPlaybackService
    from neon_messagebus.service import NeonBusService
    from neon_core.skills.service import NeonSkillService
    from neon_gui.service import NeonGUIService
    from neon_speech.service import NeonSpeechClient
    from neon_enclosure.service import NeonhardwareAbstractionLayer
    exit(0)
except Exception as e:
    print(e)
    print("Modules failed to load")
    exit(2)
