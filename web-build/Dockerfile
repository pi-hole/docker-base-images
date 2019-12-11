FROM node:12

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN wget https://github.com/tcnksm/ghr/releases/download/v0.12.0/ghr_v0.12.0_linux_amd64.tar.gz && \
    tar -xzf ghr_*_linux_amd64.tar.gz && \
    mv ghr_*_linux_amd64/ghr /usr/bin/ghr
