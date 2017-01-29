#!/bin/bash

set -x
set -e
set -u

# TODO: why is disabling host key verification needed here but not elsewhere?
# it's not needed for kube because it uses kubeconfig... but ... oh dcos, may need it...
remote_exec="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -p2200 azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com"

function teardown {
  ${remote_exec} docker service rm nginx || true
  ${remote_exec} docker network rm network || true
}

trap teardown EXIT

# this hung for me, it seems??
# adding sleep to see if it helps
sleep 10

${remote_exec} docker network create \
	--driver overlay \
	--subnet 10.0.9.0/24 \
	--opt encrypted \
	network

${remote_exec} docker service create \
	--replicas 3 \
	--name nginx \
	--network network \
	nginx

${remote_exec} docker service create \
	--name busybox \
	--network network \
	busybox \
	sleep 3000

# still not sure how to actually test it...

false
