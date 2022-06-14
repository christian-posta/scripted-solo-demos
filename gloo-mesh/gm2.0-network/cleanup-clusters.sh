
source ./env.sh

#### CLuster 1
istioctl --context $CLUSTER1 x uninstall --purge -y

helm uninstall gloo-mesh-agent \
--namespace gloo-mesh --kube-context ${CLUSTER1} 

helm uninstall gloo-mesh-agent \
--namespace gloo-mesh-gateway --kube-context ${CLUSTER1} 

kubectl --context $CLUSTER1 delete ns gloo-mesh-gateway
kubectl --context $CLUSTER1 delete ns istio-east-west
kubectl --context $CLUSTER1 delete ns istio-system
kubectl --context $CLUSTER1 delete ns sleep
kubectl --context $CLUSTER1 delete ns gloo-mesh

kubectl --context $CLUSTER1 delete -f ./resources/sample-apps/sleep.yaml -n default


#### CLuster 2
istioctl --context $CLUSTER2 x uninstall --purge  -y

helm uninstall gloo-mesh-agent \
--namespace gloo-mesh --kube-context ${CLUSTER2} 

helm uninstall gloo-mesh-agent \
--namespace gloo-mesh-gateway --kube-context ${CLUSTER2} 

kubectl --context $CLUSTER2 delete ns gloo-mesh-gateway
kubectl --context $CLUSTER2 delete ns istio-east-west
kubectl --context $CLUSTER2 delete ns istio-system
kubectl --context $CLUSTER2 delete ns sleep
kubectl --context $CLUSTER2 delete ns gloo-mesh


kubectl --context $CLUSTER2 delete -f ./resources/sample-apps/sleep.yaml -n default