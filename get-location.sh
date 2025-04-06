#!/bin/bash
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
