#!/bin/bash

set -x
set -e
set -u

# TODO: why is disabling host key verification needed here but not elsewhere?
# it's not needed for kube because it uses kubeconfig... but ... oh dcos, may need it...
remote_exec="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com"

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
