

export CILIUM_HELM_VERSION=1.11.2
export CLUSTER1=cluster1
export CLUSTER2=cluster2



cilium --context $CLUSTER2 install --cluster-id=2 --cluster-name="cluster2"  --inherit-ca $CLUSTER1

../scripts/check.sh $CILIUM_CTX kube-system



cilium --context $CLUSTER2 hubble enable

kubectl --context $CLUSTER2 -n kube-system patch svc hubble-ui -p '{"spec": {"type": "LoadBalancer"}}'

../scripts/check.sh $CILIUM_CTX kube-system