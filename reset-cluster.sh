kubectl delete ns gloo-system
kubectl delete crd $(kubectl get crd | grep solo | awk '{ print $1 }')
kubectl delete deploy --all -n default

glooctl install gateway