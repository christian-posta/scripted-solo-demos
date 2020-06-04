source env.sh

. $KUBEFED_BASE/scripts/delete-clusters.sh

kubectl config delete-context cluster1
kubectl config delete-context cluster2