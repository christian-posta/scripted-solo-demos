
VERSION=1.12.0

helm repo add cilium https://helm.cilium.io/

helm repo update

helm install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ingressController.enabled=true \
  --set kubeProxyReplacement=strict

