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
source "${ROOT}/scripts/common.sh"

# Ensure CLUSTER_TYPE if VALIDATE is set
if [[ "${VALIDATE:-}" == "y" ]]; then
	if [[ -z "${CLUSTER_TYPE:-}" ]]; then
		echo "you must specify CLUSTER_TYPE when VALIDATE=y"
		exit -1
	fi
fi

# Load any user set environment
if [[ -f "${ROOT}/test/user.env" ]]; then
	source "${ROOT}/test/user.env"
fi

# Ensure Cluster Definition
if [[ -z "${CLUSTER_DEFINITION}" ]]; then
	if [[ -z "${1:-}" ]]; then echo "You must specify a parameterized apimodel.json clusterdefinition"; exit -1; fi
	CLUSTER_DEFINITION="${1}"
fi

# Set Instance Name for PR or random run
if [[ ! -z "${PULL_NUMBER:-}" ]]; then
	export INSTANCE_NAME="${JOB_NAME}-${PULL_NUMBER}"
else
	export INSTANCE_NAME_DEFAULT="${INSTANCE_NAME_PREFIX}-$(printf "%x" $(date '+%s'))-${LOCATION}"
	export INSTANCE_NAME="${INSTANCE_NAME:-${INSTANCE_NAME_DEFAULT}}"
fi

make -C "${ROOT}"
deploy

if [[ "${VALIDATE:-}" != "y" ]]; then
	exit 0
fi

if [[ "${CLUSTER_TYPE}" == "kubernetes" ]]; then
	export KUBECONFIG="${ROOT}/_output/${INSTANCE_NAME}/kubeconfig/kubeconfig.${LOCATION}.json"
fi

"${ROOT}/test/cluster-tests/${CLUSTER_TYPE}/test.sh"
