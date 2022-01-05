ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}

ENV phpver="php"

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
        netcat \
    && rm -rf /var/lib/apt/lists/*