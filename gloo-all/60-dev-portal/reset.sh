DIR=$(dirname ${BASH_SOURCE})
kubectl delete apiproduct --all -n dev-portal
kubectl delete portals --all -n dev-portal
kubectl delete routes --all -n dev-portal
kubectl delete apidoc --all -n dev-portal
kubectl delete users --all -n dev-portal
kubectl delete groups --all -n dev-portal

# delete assets
kubectl delete cm -n dev-portal dev-portal-petstore-classic-api-doc-spec
kubectl delete cm -n dev-portal dev-portal-petstore-special-api-doc-spec
kubectl delete cm -n dev-portal dev-portal-petstore-image
kubectl delete cm -n dev-portal dev-portal-petstore-portal-banner-img
kubectl delete cm -n dev-portal dev-portal-petstore-portal-favicon
kubectl delete cm -n dev-portal dev-portal-petstore-portal-primary-logo 
kubectl delete secret -n dev-portal petstore-oidc-secret

# delete API keys
APIKEYS=$(kubectl get secret -n dev-portal | grep apikey | awk '{print $1}')
kubectl delete secret -n dev-portal $APIKEYS


# create default routes/users/apidco
kubectl apply -f $DIR/complete/apidoc-classic.yaml
kubectl apply -f $DIR/complete/routes-default.yaml


## hack until we have better retry for the k8s api server
## race
#cat << EOF | kubectl apply -f -
#apiVersion: v1
#binaryData:
#  image: ewog
#kind: ConfigMap
#metadata:
#  name: dev-portal-petstore-image
#  namespace: dev-portal
#---
#EOF