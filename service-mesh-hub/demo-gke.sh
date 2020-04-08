#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD



source env.sh


## Federate the meshes
kubectl --context $CLUSTER_1 apply -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: VirtualMesh
metadata:
  name: virtual-mesh
  namespace: service-mesh-hub
spec:
  meshes:
  - name: istio-istio-system-cluster-1 
    namespace: service-mesh-hub
  - name: istio-istio-system-cluster-2 
    namespace: service-mesh-hub
EOF


# check the cert signing stuff
kubectl get virtualmeshcertificatesigningrequests -A

kubectl delete pod -n service-mesh-hub -l service-mesh-hub=mesh-networking --context $CLUSTER_1
kubectl delete pod -n service-mesh-hub -l service-mesh-hub=mesh-networking --context $CLUSTER_2

kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1
kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2





## Install Bookinfo on cluster 1
kubectl label --context $CLUSTER_1 namespace default istio-injection=enabled
kubectl apply --context $CLUSTER_1 -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl apply --context $CLUSTER_1 -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'

## Install Bookinfo on cluster 2
kubectl label namespace default istio-injection=enabled --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version in (v3)' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'service=reviews' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=reviews' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app=ratings' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=ratings' --context $CLUSTER_2



## Apply traffic routing

kubectl apply --context $CLUSTER_1 -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: TrafficPolicy
metadata:
  namespace: service-mesh-hub
  name: simple
spec:
  destinationSelector:
    serviceRefs:
      services:
        - cluster: cluster-1
          name: reviews
          namespace: default
  trafficShift:
    destinations:
      - destination:
          cluster: cluster-2
          name: reviews
          namespace: default
        weight: 75
      - destination:
          cluster: cluster-1
          name: reviews
          namespace: default
        weight: 15
        subset:
          version: v1
      - destination:
          cluster: cluster-1
          name: reviews
          namespace: default
        weight: 10
        subset:
          version: v2
EOF


