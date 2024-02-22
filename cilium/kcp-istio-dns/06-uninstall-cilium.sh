

VERSION=1.13.2
NUMBER=${1:-1}

helm upgrade --install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set socketLB.enabled=false \
  --set kubeProxyReplacement=partial \
  --set k8sServiceHost=kind$NUMBER-control-plane \
  --set k8sServicePort=6443 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true  


kubectl delete po -n kube-system -l app.kubernetes.io/name=cilium-agent

sleep 10s

helm uninstall cilium -n kube-system

sleep 7s

kubectl apply -f hack-cilium-cleanup-ebpf-ds.yaml

sleep 7s

kubectl delete -f hack-cilium-cleanup-ebpf-ds.yaml