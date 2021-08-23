#!/bin/bash

sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor -y
sudo apt-get update
sudo apt-get install -y jq indicator-sysmonitor
