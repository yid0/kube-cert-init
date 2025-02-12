# k8s-cert-init

A Kubernetes tool that automatically generates and manages TLS certificates in your cluster.

## Description

k8s-cert-init is a Python-based application that creates self-signed TLS certificates and stores them as Kubernetes secrets. It's particularly useful for development and testing environments where you need TLS certificates but don't require a certificate authority.

## Features

- Generates self-signed TLS certificates
- Automatically creates/updates Kubernetes secrets
- Configurable through environment variables
- Runs as a Kubernetes deployment

## Prerequisites

- MicroK8s cluster running locally
- MicroK8s DNS and Registry addons enabled:
```bash
microk8s enable dns
microk8s enable registry
```
- kubectl command (via microk8s kubectl)
- Docker (for building the image)

## Configuration

The application can be configured using the following environment variables:

- `NAMESPACE`: Kubernetes namespace (default: "default")
- `SECRET_NAME`: Name of the secret to create/update (default: "postgres")

## Installation

1. Clone the repository

2. Build and push the Docker image to MicroK8s registry:
```bash
make build
docker tag yidoughi/k8s-cert-init:latest localhost:32000/k8s-cert-init:latest
docker push localhost:32000/k8s-cert-init:latest
```

3. Deploy to MicroK8s:
```bash
microk8s kubectl apply -k deploy/
```

4. Verify the deployment:
```bash
microk8s kubectl get pods -l app=k8s-cert-init
```

## Development

Build and run locally:
```bash
make run-all
```

Build with custom tag:
```bash
make build TAG=your-tag
```

## License

MIT License
