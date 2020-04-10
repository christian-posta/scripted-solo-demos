source ./env.sh

# Using Istio 1.4
ISTIO_DIR=/Users/ceposta/dev/istio/istio-1.4.3/


# cleanup cluster 1
helm template $ISTIO_DIR/install/kubernetes/helm/istio --namespace istio-system \
    -f $ISTIO_DIR/install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml | kubectl --context $CLUSTER_1 delete -f -

helm template $ISTIO_DIR/install/kubernetes/helm/istio-init --namespace istio-system | kubectl --context $CLUSTER_1 delete -f -      

kubectl --context $CLUSTER_1 delete ns istio-system

kubectl --context $CLUSTER_1 delete -f resources/remotecluster.yaml
kubectl --context $CLUSTER_1 delete -f resources/demosinglecluster.yaml
kubectl --context $CLUSTER_1 delete -f resources/sample.yaml

kubectl --context $CLUSTER_1 apply -f resources/clean-kube-dns.yaml

kubectl --context $CLUSTER_1 delete crd $(kubectl --context $CLUSTER_1 get crd | grep istio | awk '{ print $1 }')


# cleanup cluster 2
helm template $ISTIO_DIR/install/kubernetes/helm/istio --namespace istio-system \
    -f $ISTIO_DIR/install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml | kubectl --context $CLUSTER_2 delete -f -

helm template $ISTIO_DIR/install/kubernetes/helm/istio-init --namespace istio-system | kubectl --context $CLUSTER_2 delete -f -      

kubectl --context $CLUSTER_2 delete ns istio-system

kubectl --context $CLUSTER_2 delete -f resources/remotecluster.yaml
kubectl --context $CLUSTER_2 delete -f resources/greeting-sample.yaml
kubectl --context $CLUSTER_2 delete -f resources/greeting-otherns.yaml
kubectl --context $CLUSTER_2 delete -f resources/demosinglecluster.yaml
kubectl --context $CLUSTER_2 delete -f resources/sample.yaml

kubectl --context $CLUSTER_2 apply -f resources/clean-kube-dns.yaml

kubectl --context $CLUSTER_2 delete crd $(kubectl --context $CLUSTER_2 get crd | grep istio | awk '{ print $1 }')


