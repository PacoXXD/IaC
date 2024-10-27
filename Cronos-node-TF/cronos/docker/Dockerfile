# Base image
FROM ubuntu:20.04

# Set working directory
WORKDIR /data

# Default value for environment variable
ARG MONIKER=myvalidatornode

# Environment variables
ENV CHAIN_MAIND_DIR=chain-maind
ENV CHAIN_MAIND_HOME=/data/.chain-maind
ENV CHAIN_MAIND_VERSION=4.2.9
ENV CHAIN_MAIND_MIN_GAS_PRICES="0.025basecro"
ENV MONIKER_NAME=${MONIKER}
ENV CHAIN_ID=crypto-org-chain-mainnet-1
ENV CHAIN_MAIND_BIN=/data/chain-maind/bin/chain-maind

VOLUME /data/.chain-maind/config
VOLUME /data/.chain-maind/data

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y build-essential \
                       curl \
                       wget \
                       git \
                       jq \
                       make \
                       vim

# Create directory
RUN mkdir -pv ${CHAIN_MAIND_DIR}

# Download chain-maind binary package
RUN curl -LOJ https://github.com/crypto-org-chain/chain-main/releases/download/v${CHAIN_MAIND_VERSION}/chain-main_${CHAIN_MAIND_VERSION}_Linux_x86_64.tar.gz && \
    tar -C ${CHAIN_MAIND_DIR} -zxvf chain-main_${CHAIN_MAIND_VERSION}_Linux_x86_64.tar.gz

COPY start.sh /data/start.sh
RUN chmod +x /data/start.sh

# Expose ports
EXPOSE 1317 26657

# Start Validator
CMD ["/data/start.sh"]
#CMD ["tail", "-f", "/etc/hosts"] # Alternative command to keep container running
