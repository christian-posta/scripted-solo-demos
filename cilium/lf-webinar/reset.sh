#!/bin/bash


kubectl delete CiliumNetworkPolicy --all

kubectl delete NetworkPolicy --all

kubectl delete ns sleep2

kubectl delete -f apps/helloworld.yaml
kubectl delete -f apps/sleep.yaml

kubectl label ns default proj-

kubectl delete authorizationpolicy --all
istioctl x uninstall -y --purge 
kubectl delete ns istio-system

kubectl label ns default istio-injection-
