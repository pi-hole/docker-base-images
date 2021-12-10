FROM debian:buster-slim

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        grep \
        dnsutils \
        git \
        iproute2 \
        ca-certificates \
        cron \
        curl \
        iputils-ping \
        lsof \
        psmisc \
        sudo \
        unzip \
        idn2 \
        sqlite3 \
        libcap2-bin \
        dns-root-data \
        libcap2 \
        lighttpd \
        php7.3-common \
        php7.3-cgi \
        php7.3-sqlite3 \
        php7.3-xml \
        php7.3-intl \
        php7.3-json \
    && rm -rf /var/lib/apt/lists/*