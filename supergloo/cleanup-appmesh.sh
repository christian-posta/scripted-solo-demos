

kubectl delete ns bookinfo-appmesh
kubectl delete secret aws -n supergloo-system
kubectl delete mesh demo-appmesh -n supergloo-system
kubectl delete routingrule split-reviews -n supergloo-system
. cleanup-appmesh-resources.sh demo-appmesh

