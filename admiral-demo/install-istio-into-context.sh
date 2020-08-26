CLUSTER_1=$1
# Using Istio 1.6
export ISTIO_DIR=/Users/ceposta/dev/istio/latest-1.6



#####################
#Set up Cluster 1
#####################
echo "Installing onto Cluster 1: $CLUSTER_1"


kubectl --context $CLUSTER_1 create ns istio-system

# Create known CA/Root
echo "Creating cacert"
kubectl --context $CLUSTER_1 create secret generic cacerts -n istio-system \
    --from-file=$ISTIO_DIR/samples/certs/ca-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/ca-key.pem \
    --from-file=$ISTIO_DIR/samples/certs/root-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/cert-chain.pem

# Install Istio
istioctl1.6 install -f $ISTIO_DIR/manifests/examples/multicluster/values-istio-multicluster-gateways.yaml --context $CLUSTER_1

echo "Installing Istio"
echo "Go Check it"
  

echo "Updating DNS"

kubectl --context $CLUSTER_1 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["$(kubectl --context $CLUSTER_1 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
EOF


# Delete Istio's envoy filter for translating global to svc.cluster.local at istio-ingressgateway because we don't need that as Admiral generates Service Entries for cross cluster communication to just work!
kubectl --context $CLUSTER_1 delete envoyfilter istio-multicluster-ingressgateway -n istio-system    


