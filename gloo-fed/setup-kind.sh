#!/bin/bash

set -ex


kind create cluster --name "local"

# Add locality labels to remote kind cluster for discovery
(cat <<EOF | kind create cluster --name remote --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
# - role: worker
kubeadmConfigPatches:
- |
  kind: InitConfiguration
  nodeRegistration:
    kubeletExtraArgs:
      node-labels: "topology.kubernetes.io/region=us-east-1,topology.kubernetes.io/zone=us-east-1c"
EOF
)


# Install gloo to cluster $2
kubectl config use-context kind-remote
kubectl create namespace gloo-system
helm install gloo https://storage.googleapis.com/solo-public-helm/charts/gloo-1.5.0-beta5.tgz \
 --namespace gloo-system \
 --set gatewayProxies.gatewayProxy.service.type=NodePort
kubectl -n gloo-system rollout status deployment gloo --timeout=2m
kubectl -n gloo-system rollout status deployment discovery --timeout=2m
kubectl -n gloo-system rollout status deployment gateway-proxy --timeout=2m
kubectl -n gloo-system rollout status deployment gateway --timeout=2m
kubectl patch settings -n gloo-system default --type=merge -p '{"spec":{"watchNamespaces":["gloo-system", "default"]}}'

# Generate downstream cert and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   -keyout tls.key -out tls.crt -subj "/CN=solo.io"

# Generate upstream ca cert and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   -keyout mtls.key -out mtls.crt -subj "/CN=solo.io"

# Install glooctl
GLOOCTL=$(which glooctl || true)
if [ "$GLOOCTL" == "" ]; then
  GLOO_VERSION=v1.4.1 curl -sL https://run.solo.io/gloo/install | sh
  export PATH=$HOME/.gloo/bin:$PATH
fi

glooctl create secret tls --name failover-downstream --certchain tls.crt --privatekey tls.key --rootca mtls.crt

# Apply failover gateway and service
kubectl apply -f - <<EOF
apiVersion: gateway.solo.io/v1
kind: Gateway
metadata:
  name: failover-gateway
  namespace: gloo-system
  labels:
    app: gloo
spec:
  bindAddress: "::"
  bindPort: 15443
  tcpGateway:
    tcpHosts:
    - name: failover
      sslConfig:
        secretRef:
          name: failover-downstream
          namespace: gloo-system
      destination:
        forwardSniClusterName: {}

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: gloo
    gateway-proxy-id: gateway-proxy
    gloo: gateway-proxy
  name: failover
  namespace: gloo-system
spec:
  ports:
  - name: failover
    nodePort: 32000
    port: 15443
    protocol: TCP
    targetPort: 15443
  selector:
    gateway-proxy: live
    gateway-proxy-id: gateway-proxy
  sessionAffinity: None
  type: NodePort
EOF

# Revert back to cluster context $1
kubectl config use-context kind-local

# Install gloo-ee to cluster $1
kubectl create namespace gloo-system
helm install gloo https://storage.googleapis.com/gloo-ee-helm/charts/gloo-ee-1.4.0.tgz \
  --namespace gloo-system \
  --set rateLimit.enabled=false \
  --set global.extensions.extAuth.enabled=false \
  --set observability.enabled=false \
  --set apiServer.enable=false \
  --set prometheus.enabled=false \
  --set grafana.defaultInstallationEnabled=false \
  --set gloo.gatewayProxies.gatewayProxy.service.type=NodePort
kubectl -n gloo-system rollout status deployment gloo --timeout=2m
kubectl -n gloo-system rollout status deployment discovery --timeout=2m
kubectl -n gloo-system rollout status deployment gateway-proxy --timeout=2m
kubectl -n gloo-system rollout status deployment gateway --timeout=2m

glooctl create secret tls --name failover-upstream --certchain mtls.crt --privatekey mtls.key

rm *.crt
rm *.key
