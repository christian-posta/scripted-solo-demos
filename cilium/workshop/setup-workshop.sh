
CILIUM_ROOT_DIR="/home/solo/dev/cilium/"
export CILIUM_HELM_VERSION=1.12.0-rc2
export CILIUM_CTX=cilium

../scripts/deploy-multi-without-cni.sh 1 cilium us-west us-west-1


helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium --version $CILIUM_HELM_VERSION \
   --namespace kube-system \
   --set kubeProxyReplacement=partial \
   --set hostServices.enabled=false \
   --set externalIPs.enabled=true \
   --set nodePort.enabled=true \
   --set hostPort.enabled=true \
   --set bpf.masquerade=false \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

../scripts/check.sh $CILIUM_CTX kube-system

helm upgrade --install cilium cilium/cilium --version 1.12.0-rc2 \
   --namespace kube-system \
   --set hubble.enabled=true \
   --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true \
   --set prometheus.enabled=true \
   --set operator.prometheus.enabled=true \
   --set kubeProxyReplacement=partial \
   --set hostServices.enabled=false \
   --set externalIPs.enabled=true \
   --set nodePort.enabled=true \
   --set hostPort.enabled=true \
   --set bpf.masquerade=false \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

../scripts/check.sh $CILIUM_CTX kube-system

kubectl -n kube-system patch svc hubble-ui -p '{"spec": {"type": "LoadBalancer"}}'

# Install bookinfo

kubectl create namespace bookinfo
kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/bookinfo/platform/kube/bookinfo.yaml


kubectl -n bookinfo patch svc productpage -p '{"spec": {"type": "LoadBalancer"}}'

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.11/examples/kubernetes/addons/prometheus/monitoring-example.yaml
kubectl -n cilium-monitoring patch svc grafana -p '{"spec": {"type": "LoadBalancer"}}'

../scripts/check.sh $CILIUM_CTX cilium-monitoring

cilium status
