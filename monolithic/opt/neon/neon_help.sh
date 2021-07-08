#!/usr/bin/env bash

echo
echo -e "\e[33mNeon\e[0m"
echo

echo
echo "Neon-specific commands you can use from the Linux command prompt:"
echo -e "  neon-cli-client       command line client, useful for debugging"
echo -e "  neon-monitor          see all bus messages live, useful for debugging"
echo

echo
echo "Scripting utilities:"
echo -e "  neon-listen           start listening for a voice command"
echo -e "  neon-send <msg>       send a bus message"
echo -e "  neon-speak <phr>      have Neon speak a phrase to the user"
echo -e "  neon-say-to <utt>     send an utterance to Neon as if spoken by a user"
echo -e "  neon-play <uri>       play with neon audio service"
echo

echo "System commands:"
echo "  neon-start               start neon"
echo "  neon-restart             restart neon"
echo "  neon-stop                stop neon"
echo "  neon-update              update neon"
echo "  neon-reset               factory reset neon"
echo "  neon-wifi                enable wifi setup"
echo

echo
echo "Other:"
echo "  neon-help             display this message"
echo
echo -e "For more information, see \e[33mneon.ai\e[0m"
