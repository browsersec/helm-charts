# KubeBrowse Helm Chart

[![Release Charts](https://github.com/browsersec/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/browsersec/helm-charts/actions/workflows/release.yml) [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/kubebrowse)](https://artifacthub.io/packages/search?repo=kubebrowse)

A Helm chart for KubeBrowse, a secure browser sandbox environment that provides isolated browsing sessions in Kubernetes.

## Installation

### Add Helm Repository

```bash
helm repo add browsersec https://browsersec.github.io/helm-charts
helm repo update
```

### Install Chart

```bash
# Install with default values (development)
helm install kubebrowse browsersec/kubebrowse

# Install with production values
helm install kubebrowse browsersec/kubebrowse -f values-prod.yaml

# Install in specific namespace
helm install kubebrowse browsersec/kubebrowse --namespace browser-sandbox --create-namespace
```

## Configuration

See [values.yaml](./values.yaml) for configuration options.

### Key Configuration

- `api.replicas`: Number of API replicas
- `postgres.storage`: Database storage size
- `oauth.github`: GitHub OAuth configuration
- `environment`: Environment (development/production)

## Components

- API Backend (Ruby/Sinatra)
- Frontend (React/Vue.js)
- PostgreSQL Database
- Redis Cache
- Guacamole Daemon
- MinIO Object Storage

## Release Process

```bash
# Test everything locally
./scripts/test.sh

# Release a new version
./scripts/release.sh 1.2.0
```

## Links

- [Chart Repository](https://browsersec.github.io/helm-charts)
- [Source Code](https://github.com/browsersec/KubeBrowse)
- [Documentation](https://github.com/browsersec/KubeBrowse/wiki)