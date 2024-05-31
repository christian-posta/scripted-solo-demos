
## Need to install the Gateway API 1.0 CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/experimental/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml


VERSION=1.15.1
NUMBER=${1:-1}

helm repo add cilium https://helm.cilium.io/

helm repo update

# need kubeProxyReplacement=true for Gateway
# need l7Proxy=true for Gateway
# need gatewayAPI.enabled=true (by default it's not enabled; they caution it's not had much feedback)

helm install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=strict \
  --set l7Proxy=true \
  --set gatewayAPI.enabled=true \
  --set externalIPs.enabled=true \
  --set bpf.masquerade=false \
  --set image.pullPolicy=IfNotPresent \
  --set hubble.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set encryption.enabled=true \
  --set encryption.type=wireguard \
  --set authentication.mutual.spire.enabled=true \
  --set authentication.mutual.spire.install.enabled=true\
  --set k8sServiceHost=kind$NUMBER-control-plane \
  --set k8sServicePort=6443 


