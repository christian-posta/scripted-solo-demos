source ./env.sh

killall kubectl

echo "restoring upstream"
kubectl --context $LOCAL_CLUSTER_CONTEXT delete upstream -n gloo-system default-echo-10000

echo "restoring state of virtual services"
kubectl delete -f resources/failover-scheme.yaml
kubectl delete -f resources/federated-default-vs.yaml
kubectl --context $LOCAL_CLUSTER_CONTEXT delete vs gloo-system federated-default-vs 
kubectl --context $REMOTE_CLUSTER_CONTEXT delete vs gloo-system federated-default-vs 

echo "removing gloo federation plane"
./glooctl uninstall federation
kubectl delete ns gloo-fed --context $LOCAL_CLUSTER_CONTEXT
kubectl delete ns gloo-fed --context $REMOTE_CLUSTER_CONTEXT
kubectl --context $LOCAL_CLUSTER_CONTEXT delete clusterrolebinding $(kubectl --context $LOCAL_CLUSTER_CONTEXT get clusterrolebinding |  grep gloo-fed)
kubectl --context $LOCAL_CLUSTER_CONTEXT delete clusterrole $(kubectl --context $LOCAL_CLUSTER_CONTEXT get clusterrole |  grep gloo-fed)

echo "reapplying services"
kubectl --context $LOCAL_CLUSTER_CONTEXT apply -f ./resources/echo-svc-cluster-1.yaml
kubectl --context $REMOTE_CLUSTER_CONTEXT apply -f ./resources/echo-svc-cluster-2.yaml

sleep 5s

## Add health checks
kubectl patch --context $LOCAL_CLUSTER_CONTEXT upstream -n gloo-system default-echo-10000 --type=merge -p "
spec:
 healthChecks:
 - timeout: 1s
   interval: 1s
   unhealthyThreshold: 1
   healthyThreshold: 1
   httpHealthCheck:
     path: /health
"

kubectl patch --context $REMOTE_CLUSTER_CONTEXT upstream -n gloo-system default-echo-10000 --type=merge -p "
spec:
 healthChecks:
 - timeout: 1s
   interval: 1s
   unhealthyThreshold: 1
   healthyThreshold: 1
   httpHealthCheck:
     path: /health
"

#kubectl --context $LOCAL_CLUSTER_CONTEXT rollout restart -n gloo-system deploy/gloo
#kubectl --context $LOCAL_CLUSTER_CONTEXT rollout restart -n gloo-system deploy/gateway-proxy
#kubectl --context $REMOTE_CLUSTER_CONTEXT rollout restart -n gloo-system deploy/gloo
#ubectl --context $REMOTE_CLUSTER_CONTEXT rollout restart -n gloo-system deploy/gateway-proxy