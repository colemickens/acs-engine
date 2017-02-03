# Prow

## Overview

## Requirements

1. Have a cluster.

## Deployment

1. `kubectl apply -f ./nginx-ingress`
2. `./create-azure-secret.sh`
3. `./create-secrets.sh`
4. Manual steps:
  - Setup dns based on domain
  - Setup webhook based on domain
5. Deploy prow:
   1. `export GOPATH=...`
   2. `make deploy-prow`
