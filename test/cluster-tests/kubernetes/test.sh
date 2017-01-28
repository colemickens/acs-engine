#!/bin/bash

# exit on errors
set -e
# exit on unbound variables
set -u
# verbose logging
set -x

EXPECTED_NODE_COUNT="${EXPECTED_NODE_COUNT:-4}"
EXPECTED_DNS="${EXPECTED_DNS:-2}"
EXPECTED_DASHBOARD="${EXPECTED_DASHBOARD:-1}"

namespace="namespace-${RANDOM}"
echo "Running test in namespace: ${namespace}"
trap teardown EXIT

function teardown {
  kubectl delete namespaces ${namespace}
}

###### Check node count
wait=5
count=20
while (( $count > 0 )); do
  node_count=$(kubectl get nodes --no-headers | wc | awk '{print $1}')
  if (( ${node_count} == ${EXPECTED_NODE_COUNT} )); then break; fi
  sleep 5; count=$((count-1))
done
if (( $count == 0 )); then
  echo "gave up waiting for apiserver / node counts"; exit -1
fi

###### Wait for no more container creating
#wait=5
#count=20
#while (( $count > 0 )); do
#  node_count=$(kubectl get nodes --no-headers | wc | awk '{print $1}')
#  if (( ${node_count} == ${EXPECTED_NODE_COUNT} )); then break; fi
#  sleep 5; count=$((count-1))
#done
#if (( $count == 0 )); then
#  echo "gave up waiting for apiserver / node counts"; exit -1
#fi


count=0;
while (( ${count} < 20 )); do
  echo "Waiting for Pods to all leave ContainerCreating"
  creating=$(kubectl get pods --namespace=${kube-system} | grep ContainerCreating | wc | awk '{print $1}')
  if [[ ${creating} == 0 ]]; then
    break
  fi
  count=$((count+1))
  sleep 5
done

###### Check for Kube-DNS
echo "Testing system tools are running"
running=$(kubectl get pods --namespace=kube-system | grep kube-dns | grep Running | wc | awk '{print $1}')
if [[ ${running} != ${EXPECTED_DNS} ]]; then
  echo "Unexpected number of DNS servers: ${running}"
  kubectl get pods --namespace=kube-system
  exit 1
fi

###### Check for Kube-Dashboard
echo "Testing system tools are running"
running=$(kubectl get pods --namespace=kube-system | grep kubernetes-dashboard | grep Running | wc | awk '{print $1}')
if [[ ${running} != ${EXPECTED_DASHBOARD} ]]; then
  echo "Unexpected number of DASHBOARD servers: ${running}"
  kubectl get pods --namespace=kube-system
  exit 1
fi

###### Check for Kube-Proxys
echo "Testing proxies are running"
running=$(kubectl get pods --namespace=kube-system | grep kube-proxy | grep Running | wc | awk '{print $1}')
if [[ ${running} != ${EXPECTED_NODE_COUNT} ]]; then
  echo "Unexpected number of proxies running: ${running}"
  kubectl get pods --namespace=kube-system
  exit 1
fi

###### Testing an nginx deployment
echo "Testing deployments"
kubectl create namespace ${namespace}

kubectl run --image=nginx nginx --namespace=${namespace}
count=0
while [[ ${count} < 10 ]]; do
  echo "Waiting for Pod to run"
  running=$(kubectl get pods --namespace=${namespace} | grep nginx | grep Running | wc | awk '{print $1}')
  if [[ ${running} == 1 ]]; then
    break
  fi
  count=$((count+1))
  sleep 5
done

if [[ ${count} == 10 ]]; then
  echo "Deployment failed."
  kubectl get all --namespace=${namespace}
  exit 1
fi

kubectl expose deployments/nginx --namespace=${namespace} --port=80

# TODO actually check status here.
# TODO actually create an LB and ensure it comes up correctly...
sleep 10

kubectl run busybox --image=busybox --attach=true --restart=Never --namespace=${namespace} -- wget nginx

