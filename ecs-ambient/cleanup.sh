#!/bin/bash


kubectl --context ceposta-eks-3 delete -f resources/faultinjection.yaml
kubectl --context ceposta-eks-3 delete -f resources/add-headers.yaml
kubectl --context ceposta-eks-3 delete -f resources/deny-shell-ecs-to-httpbin.yaml
kubectl --context ceposta-eks-3 delete -f resources/default-ns.yaml
kubectl --context ceposta-eks-3 label ns default istio.io/use-waypoint-
istioctl --context ceposta-eks-3 waypoint delete waypoint --namespace default