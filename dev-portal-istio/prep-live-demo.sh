
echo "NOTE: This script preps for live demo on GKE with DNS! Not localhost!"
echo "Make sure to use names petstore, petstore-plan, petstore-portal for the product, plan, portal"
kubectl apply -f resources/petstore-routes.yaml
kubectl apply -f resources/user-ceposta.yaml

. ./setup-dns.sh
. ./port-forward-all.sh