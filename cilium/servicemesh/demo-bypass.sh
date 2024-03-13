#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD



kubectl apply -f ./resources/helloworld-v1-policy.yaml
kubectl apply -f ./resources/helloworld-v2-policy.yaml
./call-combinations.sh

IDENTITY_ID=$(kubectl get ciliumendpoints.cilium.io -l app=sleep,version=v1 -o jsonpath='{.items[0].status.identity.id}')


kubectl scale deploy/sleep-v1 --replicas=15
kubectl wait pods -n default -l app=sleep,version=v1 --for condition=Ready

kubectl exec -n kube-system ds/cilium -c cilium-agent -- cilium map get cilium_ipcache | grep $IDENTITY_ID

