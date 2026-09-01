FROM ghcr.io/home-assistant/amd64-base:3.22

ARG BUILD_VERSION

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="amd64"

RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    ebusd

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
