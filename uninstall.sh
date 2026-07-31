#!/bin/bash

pkill -f locindicator.py

if [ -f "$HOME/.config/autostart/locindicator.desktop" ]; then
  rm "$HOME/.config/autostart/locindicator.desktop"
fi

# Cleanup below is for installs made before locindicator dropped its
# indicator-sysmonitor dependency; harmless no-op on fresh installs.
pkill -f /usr/bin/indicator-sysmonitor

if [ -f /usr/bin/indicator-sysmonitor ]; then
  sudo rm /usr/bin/indicator-sysmonitor
fi

if [ -f "$HOME/.indicator-sysmonitor.json" ]; then
  rm "$HOME/.indicator-sysmonitor.json"
fi

if [ -f "$HOME/.config/autostart/indicator-sysmonitor.desktop" ]; then
  rm "$HOME/.config/autostart/indicator-sysmonitor.desktop"
fi
