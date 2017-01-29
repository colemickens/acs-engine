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

INSTANCE_NAME="${INSTANCE_NAME:-weeklytest}"
RESOURCE_GROUP="${INSTANCE_NAME:-acs-weekly-dcos}"

SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"

usage() { echo "Usage: $0 [-h <hostname>] [-u <username>]" 1>&2; exit 1; }

while getopts ":h:u:" o; do
    case "${o}" in
        h)
            host=${OPTARG}
            ;;
        u)
            user=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ ! -z $1 ]]; then
  usage
fi

if [[ -z $host ]]; then
  host=$(az acs show --resource-group=${RESOURCE_GROUP} --name=${INSTANCE_NAME} --query=masterProfile.fqdn | sed -e 's/^"//' -e 's/"$//')
fi

if [[ -z $user ]]; then
  user=$(az acs show --resource-group=${RESOURCE_GROUP} --name=${INSTANCE_NAME} --query=linuxProfile.adminUsername | sed -e 's/^"//' -e 's/"$//')
fi

echo $host

remote_exec="ssh -i ${SSH_KEY} ${user}@${host}"

function teardown {
  ${remote_exec} dcos marathon app remove /web
}

# TODO: this might break the jenkins job if the jenkisn job just pulls test.sh directly and not the dir...
scp -i ${SSH_KEY} ${DIR}/marathon.json ${user}@${host}:marathon.json

trap teardown EXIT

${remote_exec} dcos marathon app add marathon.json

count=0
while [[ ${count} < 10 ]]; do
  count=(count + 1)
  running=$(${remote_exec} dcos marathon app show /web | jq .tasksRunning)
  if [[ "${running}" == "3" ]]; then
    echo "Found 3 running tasks"
    break
  fi
  sleep ${count}
done

if [[ "${running}" == "3" ]]; then
  echo "Deployment succeeded"
else
  echo "Deployment failed"
  exit 1
fi
