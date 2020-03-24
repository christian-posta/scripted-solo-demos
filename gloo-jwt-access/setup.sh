kubectl apply -f resources/petstore.yaml

kubectl apply -f resources/petstore-vs.yaml

sleep 3s

curl -v $(glooctl proxy url)/api/pets