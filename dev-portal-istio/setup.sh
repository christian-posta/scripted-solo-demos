# make sure Istio and the dev portal are running
istioctl manifest apply -y

#kubectl create ns dev-portal
#helm repo add istio-dev-portal https://storage.googleapis.com/istio-dev-portal-helm
#helm repo update
#helm install idp istio-dev-portal/istio-dev-portal -n dev-portal

install-idp

kubectl apply -f resources/petstore-classic-manifest.yaml
kubectl apply -f resources/petstore-special-manifest.yaml

VERSION=$(kubectl get deploy -n dev-portal admin-server -o yaml | grep idp-admin-server | grep image | cut -d '/' -f 2)

echo "On istio-dev-portal version $VERSION"