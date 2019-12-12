FROM node:12

ARG ghrversion=0.13.0
   
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar -xzf ghr_*_linux_amd64.tar.gz && \
    tar --strip-components=1 -C /usr/bin/ -xz \
    mv ghr_*_linux_amd64/ghr /usr/bin/ghr
    ghr_v${ghrversion}_linux_amd64/ghr
