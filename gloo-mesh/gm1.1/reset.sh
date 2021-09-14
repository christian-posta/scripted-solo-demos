source env.sh

kubectl --context $CLUSTER_1 apply -k resources/sample-apps/overlays/cluster1 -n istioinaction

kubectl --context $CLUSTER_2 apply -k resources/sample-apps/overlays/cluster2 -n istioinaction


# Get all of the sample apps back online
kubectl --context $CLUSTER_1 scale deploy/web-api -n istioinaction --replicas=1
kubectl --context $CLUSTER_2 scale deploy/web-api -n istioinaction --replicas=1

kubectl --context $CLUSTER_1 scale deploy/recommendation -n istioinaction --replicas=1
kubectl --context $CLUSTER_2 scale deploy/recommendation -n istioinaction --replicas=1

kubectl --context $CLUSTER_1 scale deploy/purchase-history-v1 -n istioinaction --replicas=1
kubectl --context $CLUSTER_2 scale deploy/purchase-history-v1 -n istioinaction --replicas=1

