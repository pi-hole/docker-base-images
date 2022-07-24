ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION:-v3.14}

ARG ALPINE_VERSION
ENV phpver="php"

RUN { \
    echo 'https://dl-cdn.alpinelinux.org/alpine/edge/main/' \
    echo 'https://dl-cdn.alpinelinux.org/alpine/edge/community/' \
    } >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
    # Packages Specific to Docker:
    procps \
    xz \
    # Dependencies expected by Pi-hole installer:
    grep \
    sed \
    bind-tools \
    git \
    iproute2 \
    ca-certificates \
    cronie \
    curl \
    iputils \
    psmisc \
    sudo \
    unzip \
    libidn2 \
    sqlite \
    dnssec-root \
    libcap2 \
    lighttpd \
    php \
    php-common \
    php-cgi \
    php-sqlite3 \
    php-xml \
    php-intl \
    php-json \
    netcat-openbsd \
    logrotate \
    bash \
    openssl \
    musl-locales \
    ncurses \
    libcap \
    coreutils
