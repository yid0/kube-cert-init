#!/bin/sh

set -e 

python src/main.py

echo "Script k8s-cert-init executed with success, please check the certificates inside the kubernetes cluster."

exit 0