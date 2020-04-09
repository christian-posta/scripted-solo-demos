. env-kind.sh

kind delete cluster --name $(echo $CLUSTER_1 | sed -e "s/kind-//")
kind delete cluster --name $(echo $CLUSTER_2 | sed -e "s/kind-//")