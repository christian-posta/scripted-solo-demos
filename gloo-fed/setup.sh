source ./env.sh

kubectl --context $LOCAL_CLUSTER_CONTEXT apply -f ./resources/echo-svc-cluster-1.yaml
kubectl --context $REMOTE_CLUSTER_CONTEXT apply -f ./resources/echo-svc-cluster-2.yaml

#kubectl --context $LOCAL_CLUSTER_CONTEXT apply -f ./resources/default-vs.yaml

echo "Wait for gloo"
sleep 20s

## Add health checks
kubectl patch --context $LOCAL_CLUSTER_CONTEXT upstream -n gloo-system default-echo-10000  --type=merge -p "
spec:
 healthChecks:
 - timeout: 1s
   interval: 1s
   unhealthyThreshold: 1
   healthyThreshold: 1
   httpHealthCheck:
     path: /health
"
kubectl get us -n gloo-system default-echo-10000  -o yaml