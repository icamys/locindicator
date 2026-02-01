#!/bin/bash

sudo apt-get install -y jq python3-psutil curl git gir1.2-appindicator3-0.1 meson ninja-build

git clone https://github.com/fossfreedom/indicator-sysmonitor.git
cd indicator-sysmonitor
git reset --hard cc5d095 # version the locindicator was tested against

# Building the appindicator according to its docs
mkdir build
cd build
meson setup --prefix=/usr
sudo meson install

# Cleaning up
cd ../../
rm -rf ./indicator-sysmonitor
