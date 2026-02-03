#!/bin/bash
#
# get-location.sh - Fetch and cache current location information
#
# USAGE:
#   This script is called by configure_indicator.py to provide location data
#   for the system tray indicator. It should not be called directly by users.
#
#   ./get-location.sh [option]
#
# OPTIONS:
#   ip            - Output current public IP address
#   country_code  - Output country ISO code (uppercase, e.g., US, GB, CA)
#   country_flag  - Download country flag SVG and output path in format:
#                   USE_ICON:/tmp/country-flag-<cc>.svg
#   (no option)   - Update cache only, no output
#
# CACHING:
#   Location data is fetched from api.myip.com and cached in
#   /tmp/.locindicator-current-location for 15 seconds to minimize API calls.
#   The cache file contains JSON with a timestamp field for expiration checking.
#
# DEPENDENCIES:
#   - curl: Make API requests
#   - jq: Parse JSON responses
#   - wget: Download country flag images (for country_flag option)
#
# CONFIGURATION:
#   LOCATION_API_URL          - API endpoint (default: https://api.myip.com/)
#   LOCATION_UPDATE_INTERVAL  - Cache TTL in seconds (default: 15)
#   CURRENT_LOCATION_FILEPATH - Cache file path (default: /tmp/.locindicator-current-location)
#
LOCATION_API_URL="https://api.myip.com/"
LOCATION_UPDATE_INTERVAL=15
CURRENT_LOCATION_FILEPATH="/tmp/.locindicator-current-location"
CURRENT_TIMESTAMP=$(date +%s)

if test -f "$CURRENT_LOCATION_FILEPATH" && [ "$(wc -l $CURRENT_LOCATION_FILEPATH | awk '{ print $1 }' )" == "6" ]; then
  CURRENT_LOCATION_JSON=$(cat ${CURRENT_LOCATION_FILEPATH})
  CURRENT_LOCATION_EXPIRED=$(echo "${CURRENT_LOCATION_JSON}" | jq --arg now "$CURRENT_TIMESTAMP" --arg update_interval "$LOCATION_UPDATE_INTERVAL" '.ts < (($now|tonumber) - ($update_interval|tonumber))')
  if [ "$CURRENT_LOCATION_EXPIRED" = "true" ]; then
    CURRENT_LOCATION_JSON=$(curl -s $LOCATION_API_URL | jq --arg ts "${CURRENT_TIMESTAMP}" '. + {ts: $ts|tonumber}')
  fi
else
  CURRENT_LOCATION_JSON=$(curl -s $LOCATION_API_URL | jq --arg ts "${CURRENT_TIMESTAMP}" '. + {ts: $ts|tonumber}')
fi
echo "${CURRENT_LOCATION_JSON}" >"${CURRENT_LOCATION_FILEPATH}"

if [ "$1" = "ip" ]; then
  IP=$(echo "${CURRENT_LOCATION_JSON}" | jq -r .ip)
  echo "${IP}"
fi

if [ "$1" = "country_code" ]; then
  COUNTRY_CODE=$(echo "${CURRENT_LOCATION_JSON}" | jq -r .cc)
  echo "${COUNTRY_CODE}"
fi

if [ "$1" = "country_flag" ]; then
  COUNTRY_CODE_LOWER=$(echo "$CURRENT_LOCATION_JSON" | jq -r .cc | tr '[:upper:]' '[:lower:]')
  COUNTRY_FLAG_PATH="/tmp/country-flag-${COUNTRY_CODE_LOWER}.svg"

  if [ ! -f "$COUNTRY_FLAG_PATH" ]; then
    wget -q -o /dev/null -O "${COUNTRY_FLAG_PATH}" "https://raw.githubusercontent.com/hampusborgos/country-flags/master/svg/${COUNTRY_CODE_LOWER}.svg"
  fi
  echo "USE_ICON:${COUNTRY_FLAG_PATH}"
fi
