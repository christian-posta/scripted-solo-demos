#!/bin/bash

echo "Uninstalling the SG mesh resources"
kubectl delete mesh istio-demo -n supergloo-system
kubectl delete install gloo istio-demo -n supergloo-system
kubectl delete ns supergloo-system

echo "Uninstalling Istio (all)"
kubectl delete ns istio-system
kubectl delete crd $(k get crd | grep istio | awk '{print $1 }')
kubectl delete clusterrole  $(k get clusterrole | grep istio | awk '{print $1 }')
kubectl delete clusterrolebinding  $(k get clusterrolebinding | grep istio | awk '{print $1 }')

echo "Uninstall bookinfo"
kubectl delete -n default -f https://raw.githubusercontent.com/istio/istio/1.0.6/samples/bookinfo/platform/kube/bookinfo.yaml

echo "Uninstall Gloo"
kubectl delete ns gloo-system
supergloo uninstall --name gloo