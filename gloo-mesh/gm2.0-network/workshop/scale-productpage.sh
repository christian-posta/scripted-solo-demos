REPLICA=${1:-1}
source ./env-workshop.sh

echo "Scaling product page on cluster ${CLUSTER1}"
kubectl --context ${CLUSTER1} scale deploy/productpage-v1 -n bookinfo-frontends --replicas=$REPLICA
