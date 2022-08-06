#!/bin/bash

source /home/neon/venv/bin/activate
killall ${1}
${1}