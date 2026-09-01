#!/usr/bin/with-contenv bashio

DEVICE=$(bashio::config 'bg_device')

bashio::log.info "eBUSd Multi gestart"
bashio::log.info "BG: ${DEVICE}"

exec ebusd \
    --foreground \
    --device="${DEVICE}" \
    --scanconfig \
    --loglevel=info
