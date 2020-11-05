DIR=$(dirname ${BASH_SOURCE})
kubectl apply -f $DIR/../../resources/components/consul-1.6.2.yaml -n default