FROM ethereum/client-go:alltools-release-1.11

LABEL version="1.0"
LABEL maintainer="republichenko@gmail.com"

ENV TARGET=none
ENV NETWORKID=12345
ENV SHARED_DIR=/path/to/dir
ENV CONFIG_DIR=/path/to/dir
ENV BOOTNODE_ADDRESS=0.0.0.0
ENV BOOTNODE_PORT=30303
ENV BOOTNODE_DIR=bootnode
ENV GENESIS_FILE=genesis.json

WORKDIR /home/node
COPY ./bootstrap.sh /home/node
RUN chmod +x /home/node/bootstrap.sh

ENTRYPOINT  [ "/bin/ash", "-c", "/home/node/bootstrap.sh" ]
