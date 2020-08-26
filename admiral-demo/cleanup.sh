source ./env.sh

# Using Istio 1.4
export ISTIO_DIR=/Users/ceposta/dev/istio/latest-1.6

. ./reset.sh
. ./cleanup-admiral-only.sh


# cleanup cluster 1
uninstall-istio $CLUSTER_1
kubectl --context $CLUSTER_1 apply -f resources/clean-kube-dns.yaml



# cleanup cluster 2
uninstall-istio $CLUSTER_2      
kubectl --context $CLUSTER_2 apply -f resources/clean-kube-dns.yaml

