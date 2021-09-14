source env.sh

kubectl --context $CLUSTER_1 apply -k resources/sample-apps/misbehaving/cluster1 -n istioinaction