#!/bin/bash
LOCATION_JSON=$(curl -s 'https://api.myip.com/')
COUNTRY_CODE_LOWER=$(echo "$LOCATION_JSON" | jq -r .cc | tr '[:upper:]' '[:lower:]')
COUNTRY_FLAG_PATH="/tmp/country-flag-${COUNTRY_CODE_LOWER}.png"

if [ ! -f "$COUNTRY_FLAG_PATH" ]; then
  wget -q -o /dev/null -O "${COUNTRY_FLAG_PATH}" "https://raw.githubusercontent.com/hjnilsson/country-flags/master/png100px/${COUNTRY_CODE_LOWER}.png"
fi
echo "USE_ICON:${COUNTRY_FLAG_PATH}"
