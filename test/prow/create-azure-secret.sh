#!/usr/bin/env bash

set -euo pipefail
set -x

SECRET_DIR="$HOME/secrets/"
mkdir -p "${SECRET_DIR}"
secret="${SECRET_DIR}/azure-ci-secret.yaml"

subscription_id="${SUBSCRIPTION_ID}"
tenant_id="${TENANT_ID}"
client_id="${SERVICE_PRINCIPAL_CLIENT_ID}"
client_secret="${SERVICE_PRINCIPAL_CLIENT_SECRET}"

oidc_client_id="${OIDC_CLIENT_ID}"
oidc_client_secret="${OIDC_CLIENT_SECRET}"

github_client_id="${GITHUB_CLIENT_ID}"
github_client_secret="${GITHUB_CLIENT_SECRET}"

# TODO:
github_org="Azure"
github_team="ACS"

subscription_id="$(echo -n $subscription_id | base64)"
tenant_id="$(echo -n $tenant_id | base64)"
client_id="$(echo -n $client_id | base64)"
client_secret="$(echo -n $client_secret | base64)"
oidc_client_id="$(echo -n $oidc_client_id | base64)"
oidc_client_secret="$(echo -n $oidc_client_secret | base64)"
github_client_id="$(echo -n $github_client_id | base64)"
github_client_secret="$(echo -n $github_client_secret | base64)"

github_team="$(echo -n $github_team | base64)"
github_org="$(echo -n $github_org | base64)"

cat << EOF > "${secret}"
apiVersion: v1
kind: Secret
metadata:
  name: azure-ci
type: Opaque
data:
  SUBSCRIPTION_ID: $subscription_id
  TENANT_ID: $tenant_id
  SERVICE_PRINCIPAL_CLIENT_ID: $client_id
  SERVICE_PRINCIPAL_CLIENT_SECRET: $client_secret
  # used for oauth2_proxy:
  OIDC_CLIENT_ID: $oidc_client_id
  OIDC_CLIENT_SECRET: $oidc_client_secret
  # also used for oauth2_proxy:
  GITHUB_CLIENT_ID: $github_client_id
  GITHUB_CLIENT_SECRET: $github_client_secret
  GITHUB_ORG: $github_org
  GITHUB_TEAM: $github_team

EOF

kubectl apply -f "${secret}"
