#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

###############################################################################

set -e
set -u
set -o pipefail

ROOT="${DIR}/.."

cd "${ROOT}"
make

source "${ROOT}/test/common.sh"

export INSTANCE_NAME_DEFAULT="${INSTANCE_NAME_PREFIX}-$(printf "%x" $(date '+%s'))-${LOCATION}"
export INSTANCE_NAME="${INSTANCE_NAME:-${INSTANCE_NAME_DEFAULT}}"
export CLUSTER_DEFINITION="${ROOT}/examples/kubernetes.json"

# MSI needs to overwrite this
export CLUSTER_SERVICE_PRINCIPAL_CLIENT_ID="${CLUSTER_SERVICE_PRINCIPAL_CLIENT_ID:-SERVICE_PRINCIPAL_CLIENT_ID}"
export CLUSTER_SERVICE_PRINCIPAL_CLIENT_SECRET="${CLUSTER_SERVICE_PRINCIPAL_CLIENT_ID:-SERVICE_PRINCIPAL_CLIENT_ID}"

deploy
