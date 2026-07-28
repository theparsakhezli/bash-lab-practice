FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    curl \
    jq \
    procps \
    iputils-ping \
    dnsutils \
    netcat-openbsd \
    ca-certificates \
    nano \
    vim-tiny \
    less \
    tree \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /lab
COPY . /lab
RUN chmod +x /lab/bin/*.sh 2>/dev/null || true

CMD ["bash"]
