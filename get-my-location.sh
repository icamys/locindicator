#!/bin/bash
LOCATION_JSON=$(curl -s 'https://api.myip.com/')
IP=$(echo "${LOCATION_JSON}" | jq -r .ip)
COUNTRY_CODE=$(echo "${LOCATION_JSON}" | jq -r .cc)
echo "${COUNTRY_CODE}, IP:${IP}"
