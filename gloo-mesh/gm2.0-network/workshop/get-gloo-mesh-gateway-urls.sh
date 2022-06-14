#!/bin/bash

source ./env-workshop.sh

export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443


echo "go to:"

echo "https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage"