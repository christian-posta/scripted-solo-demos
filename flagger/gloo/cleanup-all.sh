#!/bin/bash

echo "Uninstall flagger, gloo, test"

helm del --purge gloo
helm del --purge flagger
helm del --purge flagger-loadtester
helm del --purge flagger-grafana

kubectl delete crd $(kubectl get crd | grep flagger)
kubectl delete crd $(kubectl get crd | grep solo)

kubectl delete ns test
kubectl delete ns gloo-system
