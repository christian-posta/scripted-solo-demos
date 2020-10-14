. ./env.sh


kind delete cluster --name smh-management

#call rest
. ./reset.sh

# Now delete other things

# Install bookinfo into cluster 1
kubectl label namespace default istio-injection=enabled- --context $CLUSTER_1 
kubectl --context $CLUSTER_1 delete -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl --context $CLUSTER_1 delete -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'
kubectl --context $CLUSTER_1 delete -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml


kubectl label namespace default istio-injection=enabled- --context $CLUSTER_2
kubectl --context $CLUSTER_2 delete -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --context $CLUSTER_2 delete -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl delete -f resources/sleep.yaml

./delete-istio-and-resources.sh $CLUSTER_1
./delete-istio-and-resources.sh $CLUSTER_2
