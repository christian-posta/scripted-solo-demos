DIR=$(dirname ${BASH_SOURCE})
kubectl delete ns argocd
kubectl delete -f $DIR/../../resources/gloo/argocd-vs.yaml