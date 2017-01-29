#!/bin/bash

set -x
set -e
set -u

remote_exec="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -p2200 azureuser@${INSTANCE_NAME}.${LOCATION}.cloudapp.azure.com"

function teardown {
  ${remote_exec} docker service rm nginx || true
  sleep 10
  ${remote_exec} docker network rm network || true
}

trap teardown EXIT
sleep 60

${remote_exec} docker network create \
	--driver overlay \
	--subnet 10.0.9.0/24 \
	--opt encrypted \
	network

${remote_exec} docker service create \
	--replicas 3 \
	--name nginx \
	--network network \
	--publish 80:80 \
	nginx

sleep 10

# only publicagent pool is exposed to internet
wget http://${INSTANCE_NAME}0.${LOCATION}.cloudapp.azure.com:80/

# not sure what else to do to validate
