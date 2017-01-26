#!/bin/bash

####################################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
####################################################

set -eu -o pipefail
set -x

env

git clone git@github.com:colemickens/acs-engine.git
git checkout colemickens-test-prep
make
./test/deploy-k8s.sh

exit 0

git init k8s.io/test-infra --separate-git-dir=/root/.cache/git/k8s.io/test-infra
git clean -dfx
git reset --hard
git config --local user.name 'K8S Bootstrap'
git config --local user.email k8s_bootstrap@localhost
git fetch --tags https://github.com/kubernetes/test-infra master 
git checkout -B test 00515c8e737a4ca2479bd734521d3c0e7080a12d
git merge --no-ff -m 'Merge +refs/pull/1719/head:refs/pr/1719' 
