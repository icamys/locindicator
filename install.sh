#!/bin/bash

sudo apt-get install -y jq python3-psutil git gir1.2-appindicator3-0.1 meson

git clone https://github.com/fossfreedom/indicator-sysmonitor.git
cd indicator-sysmonitor || exit 1
git reset --hard cc5d095 # version the locindicator was tested against

# Building the indicator according to its docs
mkdir build && cd "$_" || exit 1
meson setup --prefix=/usr
sudo meson install

# Cleaning up
cd ../../
rm -rf ./indicator-sysmonitor
