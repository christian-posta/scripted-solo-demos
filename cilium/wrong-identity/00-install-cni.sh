
#VERSION=1.14.0
VERSION=1.12.0



helm repo add cilium https://helm.cilium.io/

helm repo update

helm install cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set socketLB.enabled=false \
  --set externalIPs.enabled=true \
  --set bpf.masquerade=false \
  --set image.pullPolicy=IfNotPresent \
  --set l7Proxy=false \
  --set encryption.enabled=true \
  --set encryption.type=wireguard
