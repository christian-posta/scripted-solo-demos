source ./env.sh
# Using Istio 1.4
export ISTIO_DIR=/Users/ceposta/dev/istio/istio-1.4.3/



#####################
#Set up Cluster 1
#####################
echo "Installing onto Cluster 1: $CLUSTER_1"
read -s

kubectl --context $CLUSTER_1 create ns istio-system

# Create known CA/Root
echo "Creating cacert"
kubectl --context $CLUSTER_1 create secret generic cacerts -n istio-system \
    --from-file=$ISTIO_DIR/samples/certs/ca-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/ca-key.pem \
    --from-file=$ISTIO_DIR/samples/certs/root-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/cert-chain.pem

# Install CRDs
echo "Installing CRDs"
helm template $ISTIO_DIR/install/kubernetes/helm/istio-init --namespace istio-system | kubectl --context $CLUSTER_1 apply -f -    

echo "Sleeping to wait for CRDs to register"
echo "Go Check them"
read -s

# Install Istio
echo "Installing Istio 1.4.3"
helm template $ISTIO_DIR/install/kubernetes/helm/istio --namespace istio-system \
    -f $ISTIO_DIR/install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml | kubectl --context $CLUSTER_1 apply -f -

echo "Installing Istio"
echo "Go Check it"
read -s    

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


#####################
#Set up Cluster 2
#####################
echo "Installing onto Cluster 2: $CLUSTER_2"
read -s

kubectl --context $CLUSTER_2 create ns istio-system

# Create known CA/Root
echo "Creating cacert"
kubectl --context $CLUSTER_2 create secret generic cacerts -n istio-system \
    --from-file=$ISTIO_DIR/samples/certs/ca-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/ca-key.pem \
    --from-file=$ISTIO_DIR/samples/certs/root-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/cert-chain.pem

# Install CRDs
echo "Installing CRDs"
helm template $ISTIO_DIR/install/kubernetes/helm/istio-init --namespace istio-system | kubectl --context $CLUSTER_2 apply -f -    

echo "Sleeping to wait for CRDs to register"
echo "Go Check them"
read -s

# Install Istio
echo "Installing Istio 1.4.3"
helm template $ISTIO_DIR/install/kubernetes/helm/istio --namespace istio-system \
    -f $ISTIO_DIR/install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml | kubectl --context $CLUSTER_2 apply -f -

echo "Installing Istio"
echo "Go Check it"
read -s    

echo "Updating DNS"
kubectl --context $CLUSTER_2 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["$(kubectl --context $CLUSTER_2 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
EOF


# Delete Istio's envoy filter for translating global to svc.cluster.local at istio-ingressgateway because we don't need that as Admiral generates Service Entries for cross cluster communication to just work!
kubectl --context $CLUSTER_2 delete envoyfilter istio-multicluster-ingressgateway -n istio-system    

