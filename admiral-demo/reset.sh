source ./env.sh


kubectl --context $CLUSTER_1 delete -f resources/sample.yaml
kubectl --context $CLUSTER_2 delete -f resources/greeting-sample.yaml
kubectl --context $CLUSTER_2 delete -f resources/greeting-otherns.yaml

kubectl --context $CLUSTER_1 delete serviceentry --all -n admiral-sync
kubectl --context $CLUSTER_2 delete serviceentry --all -n admiral-sync