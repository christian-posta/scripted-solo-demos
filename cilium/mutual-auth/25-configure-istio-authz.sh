#!/bin/bash



# add services to ambient
kubectl label namespace default istio.io/dataplane-mode=ambient


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