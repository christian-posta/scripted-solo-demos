. ./env.sh

# context and trust domain as params
./install-istio-into-context.sh $CLUSTER_1 cluster1
# sleep to let operator kick in
sleep 5s
kubectl --context $CLUSTER_1 -n istio-system rollout status deploy/istiod 



# context and trust domain as params
./install-istio-into-context.sh $CLUSTER_2 cluster2
# sleep to let operator kick in
sleep 5s
kubectl --context $CLUSTER_2 -n istio-system rollout status deploy/istiod


# Install bookinfo into cluster 1
kubectl label namespace default istio-injection=enabled --context $CLUSTER_1 --overwrite 
kubectl --context $CLUSTER_1 apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl --context $CLUSTER_1 apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'
kubectl --context $CLUSTER_1 apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_1 get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the default namespace to become ready"
  sleep 1
done


kubectl label namespace default istio-injection=enabled --context $CLUSTER_2 --overwrite
kubectl --context $CLUSTER_2 apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --context $CLUSTER_2 apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_2 get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the default namespace to become ready"
  sleep 1
done


# create smh cluster
#kind create cluster --name smh-management