#!/bin/bash

source ./env-workshop.sh


# set up workspaces
kubectl --context $MGMT apply -f lab6-workspaces.yaml
kubectl --context $CLUSTER1 apply -f lab6-workspacesettings.yaml

# set up virtual gateway routing
kubectl --context $CLUSTER1 apply -f lab7-virtualgateway.yaml
kubectl --context $CLUSTER1 apply -f lab7-bookinfo-routetable.yaml



# set up certificate management
kubectl --context $MGMT apply -f lab9-rootcert.yaml


export ENDPOINT_HTTP_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTP_GW_CLUSTER2=$(kubectl --context ${CLUSTER2} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):80
export HOST_GW_CLUSTER1=$(echo ${ENDPOINT_HTTP_GW_CLUSTER1} | cut -d: -f1)
export HOST_GW_CLUSTER2=$(echo ${ENDPOINT_HTTP_GW_CLUSTER2} | cut -d: -f1)

echo "go to:"
echo "http://${ENDPOINT_HTTP_GW_CLUSTER1}/productpage"
echo "http://${ENDPOINT_HTTP_GW_CLUSTER2}/productpage"
