#!/bin/bash

CERT_DIR="/etc/ssl/certs"
CERT_NAME="k8s-cert-init"
NAMESPACE="default"

generate_local_cert() {
    mkdir -p "$CERT_DIR/$CERT_NAME"

    openssl req -new -x509 -days 365 -nodes \
        -out "$CERT_DIR/$CERT_NAME/$CERT_NAME.crt" \
        -keyout "$CERT_DIR/$CERT_NAME/$CERT_NAME.key" \
        -subj "/CN=localhost"

    chmod 600 "$CERT_DIR/$CERT_NAME/$CERT_NAME.key"
    chmod 644 "$CERT_DIR/$CERT_NAME/$CERT_NAME.crt"
    chown -R 1001:1001 "$CERT_DIR/$CERT_NAME" 
    echo "Certificate generated successfully : $CERT_DIR/$CERT_NAME"
}

clean_local() {
    rm -rf $CERT_DIR/$CERT_NAME
    echo "$CERT_DIR/$CERT_NAME certificates cleaned."

}

create_k8s_secret() {
    kubectl create secret tls "$CERT_NAME-tls" \
        --cert="$CERT_DIR/$CERT_NAME/$CERT_NAME.crt" \
        --key="$CERT_DIR/$CERT_NAME/$CERT_NAME.key" \
        --namespace "$NAMESPACE"
    echo "TLS secret was created successfully on namespace: $NAMESPACE"
}

case "$1" in
    local)
        generate_local_cert
        ;;
    kube)
        create_k8s_secret
        ;;
    clean_local)
        clean_local
        ;;
    *)
        echo "Usage: $0 {local|kube}"
        exit 1
        ;;
esac
