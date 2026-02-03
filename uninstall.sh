#!/bin/bash
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
