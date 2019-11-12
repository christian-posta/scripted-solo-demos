#!/bin/bash

echo "Uninstalling the SG mesh resources"
kubectl delete ns supergloo-system
kubectl delete crd $(k get crd | grep supergloo | awk '{print $1 }')

echo "Uninstalling Istio (all)"
kubectl delete ns istio-system
kubectl delete crd $(k get crd | grep istio | awk '{print $1 }')
kubectl delete clusterrole  $(k get clusterrole | grep istio | awk '{print $1 }')
kubectl delete clusterrolebinding  $(k get clusterrolebinding | grep istio | awk '{print $1 }')
kubectl delete  mutatingwebhookconfigurations.admissionregistration.k8s.io istio-sidecar-injector 

kubectl delete ns linkerd
kubectl delete crd $(k get crd | grep linkerd | awk '{print $1 }')
kubectl delete clusterrole  $(k get clusterrole | grep linkerd| awk '{print $1 }')
kubectl delete clusterrolebinding  $(k get clusterrolebinding | grep linkerd| awk '{print $1 }')

echo "Uninstall bookinfo"
kubectl delete -n default -f https://raw.githubusercontent.com/istio/istio/1.0.6/samples/bookinfo/platform/kube/bookinfo.yaml

echo "Uninstall Gloo"
kubectl delete ns gloo-system
kubectl delete crd $(k get crd | grep gloo | awk '{print $1 }')
kubectl delete ns bookinfo-appmesh
kubectl delete -f https://raw.githubusercontent.com/solo-io/service-mesh-hub/master/install/service-mesh-hub.yaml

kubectl delete ns bookinfo-appmesh
kubectl delete secret aws -n supergloo-system
kubectl delete mesh demo-appmesh -n supergloo-system
kubectl delete routingrule split-reviews -n supergloo-system
. cleanup-appmesh-resources.sh demo-appmesh
