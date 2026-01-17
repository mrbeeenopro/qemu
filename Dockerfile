FROM debian:bookworm-slim

RUN apt update && apt install -y \
    qemu-system-x86 \
    qemu-utils \
    iproute2 \
    net-tools \
    curl \
    ca-certificates \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
