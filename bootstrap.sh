#!/bin/bash

INSTALL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor -y &&
  apt-get update &&
  apt-get install -y jq indicator-sysmonitor

python "${INSTALL_PATH}"/configure_indicator.py

nohup indicator-sysmonitor >/dev/null 2>&1 &
