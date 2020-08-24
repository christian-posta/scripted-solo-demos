. ./env.sh

./install-istio-into-context.sh $CLUSTER_1
./install-istio-into-context.sh $CLUSTER_2

kubectl label namespace default istio-injection=enabled --context $CLUSTER_1 --overwrite 
kubectl label namespace default istio-injection=enabled --context $CLUSTER_2 --overwrite


echo "Ready to install Bookinfo."
echo "Waiting for istio to be ready..."
kubectl --context $CLUSTER_1 get po -n istio-system -w

## Install Bookinfo on cluster 1
kubectl apply -f ../resources-common/bookinfo-cluster1.yaml --context $CLUSTER_1

## Install Bookinfo on cluster 2
kubectl apply -f ../resources-common/bookinfo-cluster2.yaml --context $CLUSTER_2

kubectl get po -w --context $CLUSTER_2
