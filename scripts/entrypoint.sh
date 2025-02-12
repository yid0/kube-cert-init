#!/bin/sh

set -e

if [ -f "/app/venv/env/.env.$K8S_CERT_INIT_ENV" ]; then
    echo "Loading environment variables from .env.$K8S_CERT_INIT_ENV..."
    set -a
    source "/app/venv/env/.env.$K8S_CERT_INIT_ENV"
    set +a
fi

exec "$@"