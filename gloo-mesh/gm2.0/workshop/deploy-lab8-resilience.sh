#!/bin/bash

source ./env-workshop.sh

export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443

echo "go to:"
echo "https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage"


echo "Deploying a fault injection policy"
kubectl --context $CLUSTER1 apply -f lab8-faultinjection-routetable.yaml
kubectl --context $CLUSTER1 apply -f lab8-faultinjection-policy.yaml


echo "Depoyed fault injection; go check it, press ENTER to set a timeout policy"
read -s
kubectl --context $CLUSTER1 apply -f lab8-retry-timeout-routetable.yaml
kubectl --context $CLUSTER1 apply -f lab8-retry-timeout-policy.yaml


echo "Deployed a timeout policy" 
echo "run ./cleanup-lab8.sh to undo these policies"
