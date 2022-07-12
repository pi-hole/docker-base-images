ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION:-bullseye-slim}

ARG DEBIAN_VERSION
ENV phpver="php"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # Packages Specific to Docker:
        procps \
        xz-utils \
        # Dependencies expected by Pi-hole installer:
        grep \
        dnsutils \
        git \
        iproute2 \
        ca-certificates \
        cron \
        curl \
        iputils-ping \
        psmisc \
        sudo \
        unzip \
        idn2 \
        sqlite3 \
        libcap2-bin \
        dns-root-data \
        libcap2 \
        lighttpd \
        php-common \
        php-cgi \
        php-sqlite3 \
        php-xml \
        php-intl \
        php-json \
        netcat-openbsd \
        lighttpd-mod-openssl \
        logrotate \
    && rm -rf /var/lib/apt/lists/*

# curl in armhf-buster's image has SSL issues. Running c_rehash fixes it.
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=923479
RUN if [ "$DEBIAN_VERSION" = "buster-slim" ]; then c_rehash; fi
