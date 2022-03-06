#!/bin/bash

source ./env-workshop.sh


kubectl --context $CLUSTER1 apply -f lab7-virtualgateway.yaml
kubectl --context $CLUSTER1 apply -f lab7-bookinfo-routetable.yaml




export ENDPOINT_HTTP_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443
export HOST_GW_CLUSTER1=$(echo ${ENDPOINT_HTTP_GW_CLUSTER1} | cut -d: -f1)

echo "go to:"
echo "http://${ENDPOINT_HTTP_GW_CLUSTER1}/productpage"