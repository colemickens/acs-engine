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

set -e
# -o pipefail
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

if [[ -z $host ]]; then
  host=$(az acs show --resource-group=${RESOURCE_GROUP} --name=${INSTANCE_NAME} --query=masterProfile.fqdn | sed -e 's/^"//' -e 's/"$//')
fi

if [[ -z $user ]]; then
  user=$(az acs show --resource-group=${RESOURCE_GROUP} --name=${INSTANCE_NAME} --query=linuxProfile.adminUsername | sed -e 's/^"//' -e 's/"$//')
fi

echo $host

# TODO: This is not backward compatible with the jenkins job normal usage, this only works when called with INSTANCE NAME (so as above... )
remote_exec="ssh -i "${SSH_KEY}" -o StrictHostKeyChecking=no azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com -p2200"
remote_cp="scp -i "${SSH_KEY}" -P 2200 -o StrictHostKeyChecking=no"

function teardown {
  ${remote_exec} dcos marathon app remove /web
}

${remote_exec} curl -O https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos
${remote_exec} chmod a+x ./dcos
${remote_exec} ./dcos config set core.dcos_url http://localhost:80

# TODO: this might break the jenkins job if the jenkins job just pulls test.sh directly and not the dir...
${remote_cp} "${DIR}/marathon.json" azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com:marathon.json

#################trap teardown EXIT

${remote_exec} ./dcos marathon app add marathon.json

count=0
while [[ ${count} -lt 25 ]]; do
  count=$((count+1))
  running=$(${remote_exec} ./dcos marathon app show /web | jq .tasksRunning)
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
  ${remote_exec} ./dcos marathon app show /web
  exit 1
fi
