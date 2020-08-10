kubectl delete -f resources/assets.yaml

kubectl delete virtualservice -n dev-portal --all
kubectl delete secret petstore-plan-c83dc965-1112-155d-9e05-6e23e4950764 -n dev-portal
kubectl delete cm dev-portal-petstore-classic-api-doc-spec  -n dev-portal
kubectl delete cm dev-portal-petstore-special-api-doc-spec  -n dev-portal
kubectl delete apiproduct --all -n dev-portal
kubectl delete portals --all -n dev-portal
kubectl delete routes --all -n dev-portal
kubectl delete apidoc --all -n dev-portal
kubectl delete users --all -n dev-portal


kubectl apply -f resources/petstore-routes.yaml
kubectl apply -f resources/user-ceposta.yaml