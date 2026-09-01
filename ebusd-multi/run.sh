#!/bin/bash
set -e

OPTIONS="/data/options.json"
CONFIG="/tmp/ebusd-config"

KELDER_DEVICE=$(jq -r '.kelder_device' "$OPTIONS")
BG_DEVICE=$(jq -r '.bg_device' "$OPTIONS")
VERDIEPING_DEVICE=$(jq -r '.verdieping_device' "$OPTIONS")
MQTT_HOST=$(jq -r '.mqtt_host' "$OPTIONS")
MQTT_PORT=$(jq -r '.mqtt_port' "$OPTIONS")
MQTT_USER=$(jq -r '.mqtt_user // ""' "$OPTIONS")
MQTT_PASSWORD=$(jq -r '.mqtt_password // ""' "$OPTIONS")

echo "[eBUSd Multi] gestart"
echo "[eBUSd Multi] Kelder: ${KELDER_DEVICE}"
echo "[eBUSd Multi] BG: ${BG_DEVICE}"
echo "[eBUSd Multi] Verdieping: ${VERDIEPING_DEVICE}"
echo "[eBUSd Multi] MQTT: ${MQTT_HOST}:${MQTT_PORT}"

mkdir -p "${CONFIG}/encon"

echo "[eBUSd Multi] Download Excellent configuratie"

curl -fsSL https://ebus.github.io/en/broadcast.csv \
    -o "${CONFIG}/broadcast.csv"

curl -fsSL https://ebus.github.io/en/memory.csv \
    -o "${CONFIG}/memory.csv"

curl -fsSL https://ebus.github.io/en/encon/broadcast.csv \
    -o "${CONFIG}/encon/broadcast.csv"

curl -fsSL https://ebus.github.io/en/encon/7c..excellent.csv \
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

COMMON_ARGS=(
    --foreground
    --scanconfig
    --configpath="${CONFIG}"
    --mqtthost="${MQTT_HOST}"
    --mqttport="${MQTT_PORT}"
    --mqttjson
    --loglevel=info
)

if [ -n "${MQTT_USER}" ]; then
    COMMON_ARGS+=(--mqttuser="${MQTT_USER}")
fi

if [ -n "${MQTT_PASSWORD}" ]; then
    COMMON_ARGS+=(--mqttpass="${MQTT_PASSWORD}")
fi

echo "[eBUSd Multi] Start Kelder -> ebusd/kelder"

ebusd \
    "${COMMON_ARGS[@]}" \
    --device="${KELDER_DEVICE}" \
    --port=8890 \
    --mqtttopic=ebusd/kelder &

PID_KELDER=$!

echo "[eBUSd Multi] Start BG -> ebusd/bg"

ebusd \
    "${COMMON_ARGS[@]}" \
    --device="${BG_DEVICE}" \
    --port=8888 \
    --mqtttopic=ebusd/bg &

PID_BG=$!

echo "[eBUSd Multi] Start Verdieping -> ebusd/verdieping"

ebusd \
    "${COMMON_ARGS[@]}" \
    --device="${VERDIEPING_DEVICE}" \
    --port=8889 \
    --mqtttopic=ebusd/verdieping &

PID_VERDIEPING=$!

trap 'kill "$PID_KELDER" "$PID_BG" "$PID_VERDIEPING" 2>/dev/null || true; wait' TERM INT

wait -n "$PID_KELDER" "$PID_BG" "$PID_VERDIEPING"
STATUS=$?

echo "[eBUSd Multi] Een ebusd proces is gestopt (status ${STATUS})"

kill "$PID_KELDER" "$PID_BG" "$PID_VERDIEPING" 2>/dev/null || true
wait || true

exit "$STATUS"
