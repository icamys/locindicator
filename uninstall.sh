#!/bin/bash
sudo apt-get remove -y jq indicator-sysmonitor
pkill -f /usr/bin/indicator-sysmonitor
rm "$HOME"/.indicator-sysmonitor.json
