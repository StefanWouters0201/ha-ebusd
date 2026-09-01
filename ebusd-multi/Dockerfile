FROM debian:bookworm-slim

ARG BUILD_VERSION

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="amd64"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        bash \
        libmosquitto1 && \
    curl -L \
        https://github.com/john30/ebusd/releases/download/26.1/ebusd-26.1_amd64-bookworm_mqtt1.deb \
        -o /tmp/ebusd.deb && \
    apt-get install -y /tmp/ebusd.deb && \
    rm -f /tmp/ebusd.deb && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
