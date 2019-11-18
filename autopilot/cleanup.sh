kubectl delete ns autoroute-operator
kubectl delete crd autoroutes.examples.io  
rm -fr autorouter
kubectl delete gateway --all
kubectl delete virtualservice --all
kubectl delete svc/echo-server
kubectl delete -f resources/echo-deploy.yaml

docker rmi -f $(docker images | grep autorouter | awk '{ print $3 }')