#!/bin/bash
set -e

DEVICE="ens:192.168.2.211:9999"

echo "[eBUSd Multi] gestart"
echo "[eBUSd Multi] BG: ${DEVICE}"

exec ebusd \
    --foreground \
    --device="${DEVICE}" \
    --scanconfig \
    --configpath=https://ebus.github.io/ \
    --configlang=en \
    --loglevel=info
