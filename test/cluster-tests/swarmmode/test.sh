#!/bin/bash

set -x
set -e
set -u

remote_exec="ssh -i ${SSH_KEY} azureuser@${INSTANCE_NAME}"

function teardown {
  # TODO: write teardown
}

scp -i ${SSH_KEY} ${HOME}/marathon.json ${user}@${host}:marathon.json

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
