#!/bin/bash

INSTALL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor -y
sudo apt-get update
sudo apt-get install -y jq indicator-sysmonitor

python3 "${INSTALL_PATH}"/configure_indicator.py "${INSTALL_PATH}"

nohup indicator-sysmonitor >/dev/null 2>&1 &
