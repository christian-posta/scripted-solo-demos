DIR=$(dirname ${BASH_SOURCE})
kubectl delete -f $DIR/../../resources/components/consul-1.6.2.yaml -n default
k delete pvc $(k get pvc | grep consul | awk '{print $ 1}')