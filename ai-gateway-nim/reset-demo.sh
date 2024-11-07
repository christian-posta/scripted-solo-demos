CONTEXT="${1:-gke-nim2}"


# consider updating to newer Gateway CRDs


source ./env.sh



echo "Using the following context: CLUSTER1: $CLUSTER1 CLUSTER2: $CLUSTER2"

# Cluster 1
# Get rid of this just in case
kubectl --context $CLUSTER1 delete -f resources/sleep.yaml

kubectl --context $CLUSTER1 scale deploy/my-nim -n nim --replicas 1
kubectl --context $CLUSTER1 apply -f resources/upstreams/
kubectl --context $CLUSTER1 apply -f resources/routing/cluster1/openai-httproute.yaml
kubectl --context $CLUSTER1 apply -f resources/routing/cluster1/nim-httproute.yaml
kubectl --context $CLUSTER1 apply -f resources/routing/cluster1/openai-routeoptions.yaml


# Cluster 2
kubectl --context $CLUSTER2 scale deploy/my-nim -n nim --replicas 1
kubectl --context $CLUSTER2 apply -f resources/upstreams/
kubectl --context $CLUSTER2 apply -f resources/routing/cluster2/openai-httproute.yaml
kubectl --context $CLUSTER2 apply -f resources/routing/cluster2/openai-routeoptions.yaml