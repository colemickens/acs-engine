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

env; printf "\n\n"

git init acs-engine --separate-git-dir="/root/.cache/git/acs-engine"
git clean -dfx
git reset --hard
git config --local user.name 'ACS Bot'
git config --local user.email 'acs-bot@microsoft.com'
git fetch --tags https://github.com/${REPO_OWNER}/${REPO_NAME} master 
git checkout -B test "${PULL_PULL_SHA}"
git merge --no-ff -m "Merge +refs/pull/${PULL_NUMBER}/head:refs/pr/${PULL_NUMBER}"

make
./test/deploy-k8s.sh
