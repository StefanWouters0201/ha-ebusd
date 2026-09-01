#!/bin/bash
set -e

OPTIONS="/data/options.json"

DEVICE=$(jq -r '.bg_device' "$OPTIONS")
MQTT_HOST=$(jq -r '.mqtt_host' "$OPTIONS")
MQTT_PORT=$(jq -r '.mqtt_port' "$OPTIONS")
MQTT_USER=$(jq -r '.mqtt_user // ""' "$OPTIONS")
MQTT_PASSWORD=$(jq -r '.mqtt_password // ""' "$OPTIONS")

echo "[eBUSd Multi] gestart"
echo "[eBUSd Multi] BG: ${DEVICE}"
echo "[eBUSd Multi] MQTT: ${MQTT_HOST}:${MQTT_PORT}"
echo "[eBUSd Multi] MQTT topic: ebusd/bg"

ARGS=(
    --foreground
    --device="${DEVICE}"
    --scanconfig
    --configpath=https://ebus.github.io/
    --configlang=en
    --mqtthost="${MQTT_HOST}"
    --mqttport="${MQTT_PORT}"
    --mqtttopic=ebusd/bg
    --mqttjson
    --loglevel=info
)

if [ -n "${MQTT_USER}" ]; then
    ARGS+=(--mqttuser="${MQTT_USER}")
fi

if [ -n "${MQTT_PASSWORD}" ]; then
    ARGS+=(--mqttpass="${MQTT_PASSWORD}")
fi

exec ebusd "${ARGS[@]}"
