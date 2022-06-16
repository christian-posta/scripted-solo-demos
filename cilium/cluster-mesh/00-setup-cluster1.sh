

export CILIUM_HELM_VERSION=1.11.2
export CLUSTER1=cluster1
export CLUSTER2=cluster2



helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium --version $CILIUM_HELM_VERSION \
   --kube-context=${CLUSTER1} \
   --namespace kube-system \
   --set cluster.name=cluster1 \
   --set cluster.id=1 \
   --set kubeProxyReplacement=strict \
   --set ipam.operator.clusterPoolIPv4PodCIDR="172.0.0.0/16"

../scripts/check.sh $CILIUM_CTX kube-system

helm upgrade --install cilium cilium/cilium --version $CILIUM_HELM_VERSION \
   --kube-context=${CLUSTER1} \
   --namespace kube-system \
   --set hubble.enabled=true \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true

../scripts/check.sh $CILIUM_CTX kube-system

kubectl --context $CLUSTER1 -n kube-system patch svc hubble-ui -p '{"spec": {"type": "LoadBalancer"}}'
