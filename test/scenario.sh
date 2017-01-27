#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [ [$SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

###############################################################################

set -e
set -u
set -o pipefail

ROOT="${DIR}/.."
source "${ROOT}/test/common.sh"

CLUSTER_DEFINITION="${CLUSTER_DEFINITION}"
CLUSTER_TYPE="${CLUSTER_TYPE}"
# all the usual suspects from user.env are required by deloy below

# Form the instance_name (used for naming RG) from the PR build info
if [[ -z "${PULL_NUMBER}" ]]; then
	INSTANCE_NAME="colemick-$(hostname)"
else

fi

make -C "${ROOT}"
deploy

if [[ "${CLUSTER_TYPE}" == "kubernetes" ]]; then
	export KUBECONFIG="${ROOT}/_output/${INSTANCE_NAME}/kubeconfig/kubeconfig.${LOCATION}.json"
fi

"${ROOT}/test/cluster-tests/${CLUSTER_TYPE}/test.sh"
