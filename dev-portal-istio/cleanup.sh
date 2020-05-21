. ./reset.sh

# make sure Istio and the dev portal are running
istioctl manifest generate | kubectl delete -f -

helm del idp -n dev-portal
kubectl delete ns dev-portal

kubectl delete -f resources/petstore-classic-manifest.yaml
kubectl delete -f resources/petstore-special-manifest.yaml