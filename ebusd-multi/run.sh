#!/bin/bash
set -e

OPTIONS="/data/options.json"
CONFIG="/tmp/ebusd-config"

DEVICE=$(jq -r '.bg_device' "$OPTIONS")
MQTT_HOST=$(jq -r '.mqtt_host' "$OPTIONS")
MQTT_PORT=$(jq -r '.mqtt_port' "$OPTIONS")
MQTT_USER=$(jq -r '.mqtt_user // ""' "$OPTIONS")
MQTT_PASSWORD=$(jq -r '.mqtt_password // ""' "$OPTIONS")

echo "[eBUSd Multi] gestart"
echo "[eBUSd Multi] BG: ${DEVICE}"
echo "[eBUSd Multi] MQTT: ${MQTT_HOST}:${MQTT_PORT}"
echo "[eBUSd Multi] MQTT topic: ebusd/bg"

mkdir -p "${CONFIG}/encon"

echo "[eBUSd Multi] Download Excellent configuratie"

curl -fsSL \
    https://ebus.github.io/en/broadcast.csv \
    -o "${CONFIG}/broadcast.csv"

curl -fsSL \
    https://ebus.github.io/en/memory.csv \
    -o "${CONFIG}/memory.csv"

curl -fsSL \
    https://ebus.github.io/en/encon/broadcast.csv \
    -o "${CONFIG}/encon/broadcast.csv"

curl -fsSL \
    https://ebus.github.io/en/encon/7c..excellent.csv \
    -o "${CONFIG}/encon/7c..excellent.csv"

echo "[eBUSd Multi] Activeer polling"

sed -i \
    -e '/,,,PressureInlet,/s/^r,/r9,/' \
    -e '/,,,PressureExhaust,/s/^r,/r9,/' \
    -e '/,,,InletFlow,/s/^r,/r9,/' \
    -e '/,,,ExhaustFlow,/s/^r,/r9,/' \
    -e '/,,,InletFanSpeed,/s/^r,/r9,/' \
    -e '/,,,ExhaustFanSpeed,/s/^r,/r9,/' \
    "${CONFIG}/encon/7c..excellent.csv"

echo "[eBUSd Multi] Poll regels:"
grep -E 'PressureInlet|PressureExhaust|InletFlow,|ExhaustFlow,|InletFanSpeed|ExhaustFanSpeed' \
    "${CONFIG}/encon/7c..excellent.csv"

ARGS=(
    --foreground
    --device="${DEVICE}"
    --scanconfig
    --configpath="${CONFIG}"
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
