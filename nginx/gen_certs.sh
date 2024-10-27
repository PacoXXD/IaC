#!/bin/bash

# Define certificate paths
DOMAIN_NAME=${DOMAIN_NAME}
CERT_DIR="/etc/nginx/certs"
CERT_CA_DIR="${CERT_DIR}/ca"
CERT_CA_KEY="${CERT_CA_DIR}/rootCA.key"
CERT_CA_CERT="${CERT_CA_DIR}/rootCA.pem"
CERT_SERVER_DIR="${CERT_DIR}/server"
CERT_SERVER_KEY="${CERT_SERVER_DIR}/server.key"
CERT_SERVER_SCR="${CERT_SERVER_DIR}/server.csr"  # Certificate Signing Request
CERT_SERVER_CERT="${CERT_SERVER_DIR}/server.crt"

# Generate CA certificate
if [ -f "${CERT_CA_KEY}" ] && [ -f "${CERT_CA_CERT}" ];then
    echo "CA key and certificate already exist, skip."
else
    mkdir -p ${CERT_CA_DIR}

    openssl genpkey -algorithm RSA -out ${CERT_CA_KEY} -pkeyopt rsa_keygen_bits:2048
    openssl req -x509 -new -nodes -key ${CERT_CA_KEY} -sha256 -days 3650 -out ${CERT_CA_CERT} -subj "/C=US/ST=State/L=City/O=Org/CN=RootCA"
    echo "CA key and certificate generated."
fi

# Generate server certificate
if [ -f "${CERT_SERVER_KEY}" ] && [ -f "${CERT_SERVER_CERT}" ];then
    echo "CA key and certificate already exist, skip."
else
    mkdir -p ${CERT_SERVER_DIR}

    openssl genpkey -algorithm RSA -out ${CERT_SERVER_KEY} -pkeyopt rsa_keygen_bits:2048
    openssl req -new -key ${CERT_SERVER_KEY} -out ${CERT_SERVER_SCR} -subj "/C=US/ST=State/L=City/O=Org/CN=${DOMAIN_NAME}"
    openssl x509 -req -in ${CERT_SERVER_SCR} -CA $CERT_CA_CERT -CAkey $CERT_CA_KEY -CAcreateserial -out ${CERT_SERVER_CERT} -days 365 -sha256

    echo "server key and certificate generated."
fi

exec "$@"
