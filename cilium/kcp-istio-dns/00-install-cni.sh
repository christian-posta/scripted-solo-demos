
VERSION=1.13.2
NUMBER=${1:-1}
helm repo add cilium https://helm.cilium.io/

helm repo update

helm install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ingressController.enabled=true \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=kind$NUMBER-control-plane \
  --set k8sServicePort=6443 

# helm upgrade --install cilium cilium/cilium --version 1.13.2 --namespace kube-system --values cilium-values.yaml --set hostRouting=true --set k8sServiceHost=E9966D81889C7E05D96E3FC6DDB5329C.gr7.us-west-2.eks.amazonaws.com  --set socketLB.hostNamespaceOnly=true

# cilium-values.yaml


