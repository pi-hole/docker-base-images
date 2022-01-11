ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}

ENV phpver="php"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # Packages Specific to Docker:
        procps \
        # Dependencies expected by Pi-hole installer:
        ca-certificates \
        cron \
        curl \
        dnsutils \
        dns-root-data \
        git \
        grep \
        idn2 \
        iproute2 \
        iputils-ping \
        libcap2 \
        libcap2-bin \
        lighttpd \
        netcat-openbsd \        
        psmisc \
        sqlite3 \
        sudo \
        unzip \
        php-cgi \
        php-common \
        php-intl \
        php-json \
        php-sqlite3 \
        php-xml \
    && rm -rf /var/lib/apt/lists/*