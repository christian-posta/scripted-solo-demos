DIR=$(dirname ${BASH_SOURCE})
kubectl delete ns gogs

kubectl delete -f $DIR/../../resources/gloo/gogs-vs.yaml 