
VERSION=1.13.2
NUMBER=${1:-1}

helm upgrade --install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ingressController.enabled=true \
  --set kubeProxyReplacement=strict \
  --set socketLB.enabled=false \
  --set k8sServiceHost=kind$NUMBER-control-plane \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true  

 
