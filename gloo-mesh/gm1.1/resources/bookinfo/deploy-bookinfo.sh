source ../../env.sh

kubectl create namespace bookinfo --context $CLUSTER_1
kubectl label namespace bookinfo istio-injection=enabled --context $CLUSTER_1 --overwrite 
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_1 -n bookinfo get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the default namespace to become ready"
  sleep 1
done

kubectl create namespace bookinfo --context $CLUSTER_2
kubectl label namespace bookinfo istio-injection=enabled --context $CLUSTER_2 --overwrite
kubectl --context $CLUSTER_2 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --context $CLUSTER_2 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_2 -n bookinfo get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the default namespace to become ready"
  sleep 1
done

kubectl --context $MGMT_CONTEXT create ns bookinfo-config