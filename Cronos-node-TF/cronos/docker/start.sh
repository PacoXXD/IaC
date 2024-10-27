#!/bin/bash
set -ex

CHAIN_MAIND_MIN_GAS_PRICES="0.025basecro"
MONIKER_NAME=$MONIKER
CHAIN_ID=crypto-org-chain-mainnet-1
CHAIN_MAIND_HOME=/data/.chain-maind
CHAIN_MAIND_BIN=/data/chain-maind/bin/chain-maind
CHAIN_MAIND_PRUNING=everything
INSTALLED=0

if [ -f "${CHAIN_MAIND_HOME}/config/genesis.json" ];then
    INSTALLED=1
fi

if [ "$INSTALLED" -eq 0 ];then
    # Initialize chain-mainnet node
    ${CHAIN_MAIND_BIN} init $MONIKER_NAME --chain-id ${CHAIN_ID} --home ${CHAIN_MAIND_HOME}

    cp -rf /data/configs/* ${CHAIN_MAIND_HOME}/config/

    # Download genesis.json
    wget https://raw.githubusercontent.com/crypto-org-chain/mainnet/main/${CHAIN_ID}/genesis.json -O ${CHAIN_MAIND_HOME}/config/genesis.json

    # 配Configure置 app.toml
    #sed -i.bak -E "/^minimum-gas-prices/ s|=.*$|=\"${CHAIN_MAIND_MIN_GAS_PRICES}\"|" ${CHAIN_MAIND_HOME}/config/app.toml
    sed -i.bak -E "s|^(minimum-gas-prices[[:space:]]+=[[:space:]]+).*$|\1\"${CHAIN_MAIND_MIN_GAS_PRICES}\"| ; \
            s|^(pruning[[:space:]]+=[[:space:]]+).*$|\1\"${CHAIN_MAIND_PRUNING}\"|" ${CHAIN_MAIND_HOME}/config/app.toml

    # Configure config.toml
    RPC_SERVER="https://rpc.mainnet.cronos-pos.org:443,https://rpc.mainnet.cronos-pos.org:443"
    LATEST_HEIGHT=$(curl -sS https://rpc.mainnet.cronos-pos.org:443/block | jq -r .result.block.header.height)
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
    TRUST_HASH=$(curl -s "https://rpc.mainnet.cronos-pos.org:443/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    PERSISTENT_PEERS="87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.cronos-pos.org:26656,e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.cronos-pos.org:26656,2c55809558a4e491e9995962e10c026eb9014655@seed-2.cronos-pos.org:26656"
    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
            s|^(moniker[[:space:]]+=[[:space:]]+).*$|\1\"$MONIKER_NAME\"| ; \
            s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC_SERVER\"| ; \
            s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
            s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
            s|^(persistent_peers[[:space:]]+=[[:space:]]+).*$|\1\"$PERSISTENT_PEERS\"| ; \
            s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ${CHAIN_MAIND_HOME}/config/config.toml
fi

# Start node
${CHAIN_MAIND_BIN} start --home=${CHAIN_MAIND_HOME}