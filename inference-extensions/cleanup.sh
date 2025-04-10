#!/bin/bash

# specify a route to the inferencepool
kubectl delete -f inference/httproute.yaml

# deploy the gateway
kubectl delete -f inference/gateway.yaml

kubectl delete -f metrics/grafana.yaml
kubectl delete -f metrics/metrics-sa.yaml

# create an inference model
kubectl delete -f inference/inferencemodel.yaml
kubectl delete -f inference/inferencepool.yaml



# Remove Grafana and Prometheus related resources
helm uninstall my-prometheus
kubectl delete namespace prometheus

helm uninstall kgateway -n kgateway-system
helm uninstall kgateway-crds -n kgateway-system

## may need this to delete the CRDs:
# kubectl patch crd inferencepools.inference.networking.x-k8s.io --type=json -p '[{"op": "remove", "path": "/metadata/finalizers"}]'
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/v0.2.0/manifests.yaml
kubectl delete namespace kgateway-system
