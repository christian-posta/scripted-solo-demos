. ./env.sh


#call rest
. ./reset.sh

# Now delete other things

## Install Bookinfo on cluster 1
kubectl delete -f ../resources-common/bookinfo-cluster1.yaml --context $CLUSTER_1

## Install Bookinfo on cluster 2
kubectl delete -f ../resources-common/bookinfo-cluster2.yaml --context $CLUSTER_2

kubectl delete -f resources/sleep.yaml

./delete-istio-and-resources.sh $CLUSTER_1
./delete-istio-and-resources.sh $CLUSTER_2



