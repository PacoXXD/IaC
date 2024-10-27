#!/bin/bash
DOMAIN_NAME=${DOMAIN_NAME}
CERT_DIR="/Users/paco/Downloads/cronos/nginx/certs"
CERT_CA_DIR="${CERT_DIR}/ca"
CERT_CA_KEY="${CERT_CA_DIR}/rootCA.key"
CERT_CA_CERT="${CERT_CA_DIR}/rootCA.pem"
CERT_SERVER_DIR="${CERT_DIR}/server"
CERT_SERVER_KEY="${CERT_SERVER_DIR}/server.key"
CERT_SERVER_SCR="${CERT_SERVER_DIR}/server.csr"
CERT_SERVER_CERT="${CERT_SERVER_DIR}/server.crt"

if [ "$#" -ne 1 ];then
    echo "please input client name"
    exit 1
fi

CLIENT_NAME=$1
CERT_CLIENT_DIR="${CERT_DIR}/client"
CERT_CLIENT_KEY="${CERT_CLIENT_DIR}/${CLIENT_NAME}.key"
CERT_CLIENT_CSR="${CERT_CLIENT_DIR}/${CLIENT_NAME}.csr"
CERT_CLIENT_CRT="${CERT_CLIENT_DIR}/${CLIENT_NAME}.crt"

mkdir -p ${CERT_CLIENT_DIR}
openssl genpkey -algorithm RSA -out $CERT_CLIENT_KEY -pkeyopt rsa_keygen_bits:2048
openssl req -new -key $CERT_CLIENT_KEY -out $CERT_CLIENT_CSR -subj "/C=US/ST=State/L=City/O=Org/CN=Client"
openssl x509 -req -in $CERT_CLIENT_CSR -CA $CERT_CA_CERT -CAkey $CERT_CA_KEY -CAcreateserial -out $CERT_CLIENT_CRT -days 365 -sha256
