#!/bin/bash

# TODO: Deprecate this wrapper when core is installed system-wide
source /home/neon/venv/bin/activate
echo ">>>Starting ${1}<<<"
case ${1} in
    neon_audio_client)
        python /usr/libexec/neon-audio.py
        ;;
    neon_messagebus_service)
        python /usr/libexec/neon-messagebus.py
        ;;
    neon_enclosure_client)
        python /usr/libexec/neon-enclosure.py
        ;;
    neon_gui_service)
        python /usr/libexec/neon-gui.py
        ;;
    neon_skills_service)
        python /usr/libexec/neon-skills.py
        ;;
    neon_speech_client)
        python /usr/libexec/neon-speech.py
        ;;
    *)
        echo "(re)starting unknown service ${1}"
        killall "${1}"
        ${1}
        ;;
esac
