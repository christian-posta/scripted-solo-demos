source ./env.sh


kubectl --context $CLUSTER_1 delete -f resources/$ADMIRAL_VERSION/remotecluster.yaml
kubectl --context $CLUSTER_1 delete -f resources/$ADMIRAL_VERSION/demosinglecluster.yaml


kubectl --context $CLUSTER_2 delete -f resources/$ADMIRAL_VERSION/remotecluster.yaml
kubectl --context $CLUSTER_2 delete -f resources/$ADMIRAL_VERSION/demosinglecluster.yaml


