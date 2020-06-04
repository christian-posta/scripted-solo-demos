source env.sh

#. $KUBEFED_BASE/scripts/delete-kubefed.sh

## Clean up cluster1
kubectl delete -f resources/deployment.yaml --context $CLUSTER_1
kubectl delete -f resources/service.yaml --context $CLUSTER_1
kubectl delete ns test-namespace --context $CLUSTER_1
