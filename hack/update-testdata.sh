#!/usr/bin/env bash

####################################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
####################################################

set -euo pipefail

ROOT="${DIR}/.."
cd "${ROOT}"

mv pkg/acsengine/testdata/disks-storageaccount/kubernetes_expected.json{.err,} || true
mv pkg/acsengine/testdata/key-vault-certs/kubernetes_expected.json{.err,} || true
mv pkg/acsengine/testdata/largeclusters/kubernetes_expected.json{.err,} || true
mv pkg/acsengine/testdata/simple/kubernetes_expected.json{.err,} || true
mv pkg/acsengine/testdata/vnet/kubernetesvnet_expected.json{.err,} || true
