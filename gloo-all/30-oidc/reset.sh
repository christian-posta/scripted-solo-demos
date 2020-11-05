DIR=$(dirname ${BASH_SOURCE})
kubectl apply -n gloo-system -f $DIR/../20-lets-encrypt-edge-tls/default-vs-tls.yaml