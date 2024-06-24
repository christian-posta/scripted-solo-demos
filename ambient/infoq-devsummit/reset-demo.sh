#!/bin/bash

kubectl delete -f resources/istio/waypoint/web-api-ns.yaml
kubectl label ns web-api istio.io/use-waypoint-

kubectl delete -f resources/istio/waypoint/recommendation-ns.yaml
kubectl label ns recommendation istio.io/use-waypoint-

kubectl delete -f resources/istio/waypoint/purchase-history-ns.yaml
kubectl label ns purchase-history istio.io/use-waypoint-

kubectl delete ap --all -n istio-system
kubectl delete ap --all -n default
kubectl delete ap --all -n web-api
kubectl delete ap --all -n recommendation
kubectl delete ap --all -n purchase-history


kubectl delete vs,gw --all -n default
kubectl delete vs,gw --all -n istio-system
kubectl delete vs,gw --all -n web-api
kubectl delete vs,gw --all -n recommendation
kubectl delete vs,gw --all -n purchase-history

kubectl delete -f ./resources/istio/trace-sample-100.yaml

kubectl label ns default istio.io/dataplane-mode-
kubectl label ns web-api istio.io/dataplane-mode-
kubectl label ns recommendation istio.io/dataplane-mode-
kubectl label ns purchase-history istio.io/dataplane-mode-

istioctl uninstall -y --purge 
kubectl delete -f ~/dev/istio/istio-1.22.0/samples/addons/
kubectl delete ns istio-system


