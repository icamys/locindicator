#!/bin/bash

INSTALL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AUTOSTART_DIR="${HOME}/.config/autostart"
AUTOSTART_PATH="${AUTOSTART_DIR}/locindicator.desktop"

mkdir -p "${AUTOSTART_DIR}"

cat >"${AUTOSTART_PATH}" <<EOF
[Desktop Entry]
Name=Location Indicator
Comment=Shows current public IP, country code and flag in the system tray
Exec=python3 "${INSTALL_PATH}/locindicator.py" "${INSTALL_PATH}"
Terminal=false
StartupNotify=false
Type=Application
Categories=Utility;
EOF

nohup python3 "${INSTALL_PATH}"/locindicator.py "${INSTALL_PATH}" >/dev/null 2>&1 &
