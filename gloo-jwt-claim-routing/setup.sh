kubectl apply -f resources/echoapp.yaml
kubectl apply -f resources/echoapp-vs.yaml
kubectl apply -f resources/echoapp-upstream.yaml

sleep 3s

curl $(glooctl proxy url)/