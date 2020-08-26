source ./env.sh


kubectl --context $CLUSTER_1 delete -f resources/sample.yaml
kubectl --context $CLUSTER_2 delete -f resources/greeting-otherns.yaml

kubectl --context $CLUSTER_1 delete serviceentry --all -n admiral-sync
kubectl --context $CLUSTER_1 delete virtualservice --all -n admiral-sync
kubectl --context $CLUSTER_1 delete destinationrule --all -n admiral-sync

kubectl --context $CLUSTER_2 delete serviceentry --all -n admiral-sync
kubectl --context $CLUSTER_2 delete virtualservice --all -n admiral-sync
kubectl --context $CLUSTER_2 delete destinationrule --all -n admiral-sync

kubectl --context $CLUSTER_1 delete po --all -n admiral

kubectl --context $CLUSTER_1 delete -f resources/sample_dep.yaml