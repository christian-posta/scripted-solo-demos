#!/bin/bash

source ./env-workshop.sh

export ENDPOINT_HTTP_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443
export HOST_GW_CLUSTER1=$(echo ${ENDPOINT_HTTP_GW_CLUSTER1} | cut -d: -f1)

echo "go to:"
echo "http://${ENDPOINT_HTTP_GW_CLUSTER1}/productpage"


echo "Deploying a fault injection policy"
kubectl --context $CLUSTER1 apply -f lab8-faultinjection.yaml

echo "Depoyed fault injection; go check it, press ENTER to set a timeout policy"
read -s
kubectl --context $CLUSTER1 apply -f lab8-retry-timeout.yaml

echo "Deployed a timeout policy" 
echo "run ./cleanup-lab8.sh to undo these policies"

