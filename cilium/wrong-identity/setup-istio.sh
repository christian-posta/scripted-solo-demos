#!/bin/bash
# setup istio and jq
curl -sL https://istio.io/downloadIstioctl | sh -
sudo mv $HOME/.istioctl/bin/istioctl /usr/local/bin/
istioctl install --set profile=minimal -y
sudo apt-get install jq -y
kubectl scale deploy istiod -n istio-system --replicas=3

# Apply services:
# Note that: hello-v1 and hello-v2 go on different nodes, and the sleep deployments go on nodes where hello are not.
echo "Depolying services and waiting for them to be ready..."
kubectl label namespace default istio-injection=enabled

kubectl rollout restart deployment/helloworld-v1
kubectl rollout restart deployment/helloworld-v2
kubectl rollout restart deployment/sleep-v1
kubectl rollout restart deployment/sleep-v2


kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT
EOF

kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: default
spec:
  {}
EOF


kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: "helloworld-v1-viewer"
  namespace: default
spec:
  selector:
    matchLabels:
      app: helloworld
      version: v1
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/sleep-v1"]
    to:
    - operation:
        methods: ["GET"]
EOF

kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: "helloworld-v2-viewer"
  namespace: default
spec:
  selector:
    matchLabels:
      app: helloworld
      version: v2
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/sleep-v2"]
    to:
    - operation:
        methods: ["GET"]
EOF