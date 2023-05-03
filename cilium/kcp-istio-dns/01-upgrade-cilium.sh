
VERSION=1.13.2

helm upgrade --install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ingressController.enabled=true \
  --set kubeProxyReplacement=strict \
  --set socketLB.hostNamespaceOnly=true 

 
