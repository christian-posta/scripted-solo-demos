# make sure Istio and the dev portal are running
istioctl manifest apply

kubectl create ns dev-portal
helm repo update
helm install idp istio-dev-portal/istio-dev-portal -n dev-portal

kubectl apply -f resources/petstore-classic-manifest.yaml
kubectl apply -f resources/petstore-special-manifest.yaml