# Using Istio 1.4
export ISTIO_DIR=/Users/ceposta/dev/istio/istio-1.4.3/

kubectl create ns istio-system

# Create known CA/Root
kubectl create secret generic cacerts -n istio-system \
    --from-file=$ISTIO_DIR/samples/certs/ca-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/ca-key.pem \
    --from-file=$ISTIO_DIR/samples/certs/root-cert.pem \
    --from-file=$ISTIO_DIR/samples/certs/cert-chain.pem

# Install CRDs
helm template $ISTIO_DIR/install/kubernetes/helm/istio-init --namespace istio-system | kubectl apply -f -    

echo "Sleeping to wait for CRDs to register"
echo "Go Check them"
read -s

# Install Istio
helm template $ISTIO_DIR/install/kubernetes/helm/istio --namespace istio-system \
    -f $ISTIO_DIR/install/kubernetes/helm/istio/example-values/values-istio-multicluster-gateways.yaml | kubectl apply -f -

echo "Installing Istio"
echo "Go Check it"
read -s    


# Update kube-dns to map *.global to istio coredns
# Use this for Kind, use the kube-dns one for GKE
#./resources/scripts/redirect-dns.sh

#Use this for k3d
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    global:53 {
        errors
        cache 30
        forward . $(kubectl get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP}):53
    }
EOF





#kubectl apply -f - <<EOF
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: kube-dns
#  namespace: kube-system
#data:
#  stubDomains: |
#    {"global": ["$(kubectl get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
#EOF


# Delete Istio's envoy filter for translating global to svc.cluster.local at istio-ingressgateway because we don't need that as Admiral generates Service Entries for cross cluster communication to just work!
kubectl delete envoyfilter istio-multicluster-ingressgateway -n istio-system    

