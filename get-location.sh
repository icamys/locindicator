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
#   If a refresh fetch fails (network blip, DNS hiccup, rate limiting), the
#   last known-good cached value is kept and reported instead of blanking the
#   sensor, with a "⚠" marker appended so the staleness is visible in the tray.
#
# DEPENDENCIES:
#   - jq: Parse JSON responses
#   - wget: Make API requests and download country flag images (for country_flag option)
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
STALE_MARKER=" ⚠"

CACHED_JSON=""
if [ -f "$CURRENT_LOCATION_FILEPATH" ]; then
  CACHED_JSON=$(cat "$CURRENT_LOCATION_FILEPATH")
fi

CACHE_VALID=0
CACHE_EXPIRED="true"
if [ -n "$CACHED_JSON" ] && echo "$CACHED_JSON" | jq -e . >/dev/null 2>&1; then
  CACHE_VALID=1
  CACHE_EXPIRED=$(echo "$CACHED_JSON" | jq --arg now "$CURRENT_TIMESTAMP" --arg update_interval "$LOCATION_UPDATE_INTERVAL" '.ts < (($now|tonumber) - ($update_interval|tonumber))')
fi

STALE=0
if [ "$CACHE_EXPIRED" = "true" ]; then
  FETCHED_JSON=$(wget -qO- "$LOCATION_API_URL" | jq --arg ts "${CURRENT_TIMESTAMP}" '. + {ts: $ts|tonumber}' 2>/dev/null)
  if [ -n "$FETCHED_JSON" ] && echo "$FETCHED_JSON" | jq -e . >/dev/null 2>&1; then
    CURRENT_LOCATION_JSON="$FETCHED_JSON"
    echo "${CURRENT_LOCATION_JSON}" >"${CURRENT_LOCATION_FILEPATH}"
  elif [ "$CACHE_VALID" = 1 ]; then
    CURRENT_LOCATION_JSON="$CACHED_JSON"
    STALE=1
  else
    CURRENT_LOCATION_JSON="{}"
    STALE=1
  fi
else
  CURRENT_LOCATION_JSON="$CACHED_JSON"
fi

MARKER=""
if [ "$STALE" = 1 ]; then
  MARKER="$STALE_MARKER"
fi

if [ "$1" = "ip" ]; then
  IP=$(echo "${CURRENT_LOCATION_JSON}" | jq -r '.ip // "N/A"')
  echo "${IP}${MARKER}"
fi

if [ "$1" = "country_code" ]; then
  COUNTRY_CODE=$(echo "${CURRENT_LOCATION_JSON}" | jq -r '.cc // "N/A"')
  echo "${COUNTRY_CODE}${MARKER}"
fi

if [ "$1" = "country_flag" ]; then
  COUNTRY_CODE_LOWER=$(echo "${CURRENT_LOCATION_JSON}" | jq -r '.cc // empty' | tr '[:upper:]' '[:lower:]')

  if [ -z "$COUNTRY_CODE_LOWER" ]; then
    echo "USE_ICON:"
  else
    COUNTRY_FLAG_PATH="/tmp/country-flag-${COUNTRY_CODE_LOWER}.svg"

    if [ ! -f "$COUNTRY_FLAG_PATH" ]; then
      wget -q -o /dev/null -O "${COUNTRY_FLAG_PATH}" "https://raw.githubusercontent.com/hampusborgos/country-flags/master/svg/${COUNTRY_CODE_LOWER}.svg"
      # Upstream SVGs ship without width/height (only a viewBox), so renderers
      # fall back to the viewBox units as the intrinsic size, which can be far
      # larger than a tray icon and makes the flag fill the whole panel height.
      sed -i '0,/<svg /s//<svg width="60" height="30" /' "${COUNTRY_FLAG_PATH}"
    fi
    echo "USE_ICON:${COUNTRY_FLAG_PATH}"
  fi
fi
