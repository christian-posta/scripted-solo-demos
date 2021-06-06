source env.sh
kubectl --context $MGMT_CONTEXT apply -f resources/virtual-mesh-acp.yaml

kubectl --context $CLUSTER_1 apply -f resources/istio/default-peer-authentication.yaml
kubectl --context $CLUSTER_2 apply -f resources/istio/default-peer-authentication.yaml

