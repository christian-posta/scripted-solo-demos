#!/bin/bash

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

kubectl label ns default istio-injection-
kubectl label ns web-api istio-injection-
kubectl label ns recommendation istio-injection-
kubectl label ns purchase-history istio-injection-


kubectl rollout restart deploy -n default
kubectl rollout restart deployment  -n web-api
kubectl rollout restart deployment  -n recommendation
kubectl rollout restart deployment  -n purchase-history
