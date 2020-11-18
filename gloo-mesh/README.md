1.
```
export MGMT_PLANE_CTX=kind-management-plane-*
export REMOTE_CTX=kind-remote-cluster-*
```


2. 
```
meshctl check
```

3.
```
kubectl get meshes -n service-mesh-hub -oyaml
```

4. 
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: VirtualMesh
metadata:
  name: virtual-mesh
  namespace: service-mesh-hub
spec:
  meshes:
  - name: istio-istio-system-management-plane
    namespace: service-mesh-hub
EOF
```

5.
```
k get virtualmeshcertificatesigningrequests.security.zephyr.solo.io -A -oyaml 
```

6.
```
kubectl delete pod -n istio-system -l app=istiod
```

7.
```
kubectl label --context $MGMT_PLANE_CTX namespace default istio-injection=enabled


kubectl apply --context $MGMT_PLANE_CTX -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl apply --context $MGMT_PLANE_CTX -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'
```

8.
```
kubectl port-forward deployments/productpage-v1 9080
```

9.
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: TrafficPolicy
metadata:
  namespace: service-mesh-hub
  name: simple
spec:
  destinationSelector:
    serviceRefs:
      services:
        - cluster: management-plane
          name: reviews
          namespace: default
  trafficShift:
    destinations:
      - destination:
          cluster: management-plane
          name: reviews
          namespace: default
        weight: 75
        subset:
          version: v1
      - destination:
          cluster: management-plane
          name: reviews
          namespace: default
        weight: 25
        subset:
          version: v2
EOF
```

10.
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: VirtualMesh
metadata:
  name: virtual-mesh
  namespace: service-mesh-hub
spec:
  enforceAccessControl: true
  meshes:
  - name: istio-istio-system-management-plane
    namespace: service-mesh-hub
EOF
```


11.
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: AccessControlPolicy
metadata:
  namespace: service-mesh-hub
  name: productpage
spec:
  sourceSelector:
    serviceAccountRefs:
      serviceAccounts:
        - name: bookinfo-productpage
          namespace: default
          cluster: management-plane
  destinationSelector:
    matcher:
      namespaces:
        - default
---
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: AccessControlPolicy
metadata:
  namespace: service-mesh-hub
  name: reviews
spec:
  sourceSelector:
    serviceAccountRefs:
      serviceAccounts:
        - name: bookinfo-reviews
          namespace: default
          cluster: management-plane
  destinationSelector:
    matcher:
      namespaces:
        - default
      labels:
        service: ratings
EOF
```

12.
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: VirtualMesh
metadata:
  name: virtual-mesh
  namespace: service-mesh-hub
spec:
  enforceAccessControl: true
  meshes:
  - name: istio-istio-system-management-plane
    namespace: service-mesh-hub
  - name: istio-istio-system-remote-cluster
    namespace: service-mesh-hub
EOF
```

CHECK STATUS UP HERE, just to be safe

13.
```
k get virtualmeshcertificatesigningrequests.security.zephyr.solo.io -A -oyaml  --context $REMOTE_CTX
```

14.
```
kubectl delete pod -n istio-system -l app=istiod --context $REMOTE_CTX
```


15.
```
kubectl label namespace default istio-injection=enabled --context $REMOTE_CTX

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version in (v3)' --context $REMOTE_CTX
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'service=reviews' --context $REMOTE_CTX
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=reviews' --context $REMOTE_CTX
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app=ratings' --context $REMOTE_CTX
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=ratings' --context $REMOTE_CTX
```

DELETE MESH NETWORKING

16.
```
kubectl apply --context $MGMT_PLANE_CTX -f - <<EOF
apiVersion: networking.zephyr.solo.io/v1alpha1
kind: TrafficPolicy
metadata:
  namespace: service-mesh-hub
  name: simple
spec:
  destinationSelector:
    serviceRefs:
      services:
        - cluster: management-plane
          name: reviews
          namespace: default
  trafficShift:
    destinations:
      - destination:
          cluster: remote-cluster
          name: reviews
          namespace: default
        weight: 75
      - destination:
          cluster: management-plane
          name: reviews
          namespace: default
        weight: 15
        subset:
          version: v1
      - destination:
          cluster: management-plane
          name: reviews
          namespace: default
        weight: 10
        subset:
          version: v2
EOF
```
