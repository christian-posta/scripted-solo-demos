
VERSION=1.13.2
NUMBER=${1:-1}

helm upgrade --install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set image.pullPolicy=IfNotPresent \
  --set image.override=quay.io/cilium/cilium:latest \
  --set debug.enabled=true \
  --set debug.verbose=datapath \
  --set ipam.mode=kubernetes  \
  --set socketLB.enabled=false \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=kind$NUMBER-control-plane \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true  

 
