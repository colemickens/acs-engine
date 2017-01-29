#!/bin/bash

set -x
set -e
set -u

remote_exec="ssh -i ${SSH_KEY} azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com"

function teardown {
  # TODO: write teardown
  echo "TODO: implement teardown"
}

${remote_exec} docker network create \
	--driver overlay \
	--subnet 10.0.9.0/24 \
	--opt encrypted \
	overlaynetwork0

${remote_exec} docker service create \
	--replicas 3 \
	--name nginxsvc0 \
	--network overlaynetwork0 \
	nginx

sleep 60

echo "trying master agent pool"
wget "http://${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com" || true
echo $?

echo "trying frst 'publicagent' pool"
wget "http://${INSTANCE_NAME}0.${LOCATION}.cloudapp.azure.com" || true
echo $?

false
