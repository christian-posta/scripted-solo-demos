#!/bin/bash

source ./env-workshop.sh




# Update to use common root cert
kubectl --context $MGMT apply -f ./policies/clean-rootcert.yaml
# set up workspaces

kubectl --context $MGMT apply -f ./policies/clean-workspaces.yaml
kubectl --context $CLUSTER1 apply -f ./policies/clean-workspacesettings.yaml
kubectl --context $CLUSTER1 apply -f ./policies/clean-virtualgateway.yaml

export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443


echo "go to:"

echo "https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage"


