#!/usr/bin/env bash

# Imphal coords
LAT="24.8108"
LON="93.9386"

DATA=$(curl -s \
  -H "User-Agent: waybar-weather" \
  "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$LAT&lon=$LON")

TEMP=$(echo "$DATA" | jq '.properties.timeseries[0].data.instant.details.air_temperature')
COND=$(echo "$DATA" | jq -r '.properties.timeseries[0].data.next_1_hours.summary.symbol_code')

# --- Icon mapping ---
case "$COND" in
clearsky*) ICON="☀️" ;;
partlycloudy*) ICON="⛅" ;;
cloudy*) ICON="☁️" ;;
rain*) ICON="🌧️" ;;
lightrain*) ICON="🌦️" ;;
heavyrain*) ICON="⛈️" ;;
snow*) ICON="❄️" ;;
fog*) ICON="🌫️" ;;
*) ICON="🌡️" ;;
esac

echo "$ICON ${TEMP}°C"
