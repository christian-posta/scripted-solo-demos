source env.sh

#. $KUBEFED_BASE/scripts/delete-kubefed.sh

## Clean up cluster1
kubectl --context $CLUSTER_1 -n kube-federation-system delete sa cluster1-cluster1   
kubectl --context $CLUSTER_1 delete secret -n kube-federation-system $(kubectl --context $CLUSTER_1 get secret -n kube-federation-system | grep $CLUSTER_1 | cut -d ' ' -f 1)
kubectl --context $CLUSTER_1 delete secret -n kube-federation-system $(kubectl --context $CLUSTER_1 get secret -n kube-federation-system | grep $CLUSTER_2 | cut -d ' ' -f 1)
kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep $CLUSTER_1 | cut -d ' ' -f 1)
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding | grep $CLUSTER_1 | cut -d ' ' -f 1)

## Clean up cluster2
kubectl --context $CLUSTER_2 -n kube-federation-system delete sa cluster2-cluster1 
kubectl --context $CLUSTER_2 delete secret -n kube-federation-system $(kubectl --context $CLUSTER_2 get secret -n kube-federation-system | grep $CLUSTER_2 | cut -d ' ' -f 1)
kubectl --context $CLUSTER_2 delete clusterrole $(kubectl --context $CLUSTER_2 get clusterrole | grep $CLUSTER_2 | cut -d ' ' -f 1)
kubectl --context $CLUSTER_2 delete clusterrolebinding $(kubectl --context $CLUSTER_2 get clusterrolebinding | grep $CLUSTER_2 | cut -d ' ' -f 1)

## Clean up kubeclusters
kubectl --context $CLUSTER_1 delete kubefedclusters -n kube-federation-system --all