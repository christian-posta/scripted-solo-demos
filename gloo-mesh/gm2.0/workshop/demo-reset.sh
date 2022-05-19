#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

source ./env-workshop-bare.sh


kubectl --context $MGMT delete -f ./bare/workspace-gateways.yaml
kubectl --context $CLUSTER1 delete -f ./bare/workspace-settings-gateway.yaml

kubectl --context $MGMT delete -f ./bare/workspace-bookinfo.yaml
kubectl --context $CLUSTER1 delete -f ./bare/workspace-settings-bookinfo.yaml


kubectl --context $CLUSTER1 delete -f ./bare/virtualdestination.yaml
kubectl --context $CLUSTER1 delete -f ./bare/virtualgateway.yaml
kubectl --context $CLUSTER1 delete -f ./bare/routetable.yaml
