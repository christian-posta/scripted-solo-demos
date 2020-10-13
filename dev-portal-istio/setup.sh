# make sure Istio and the dev portal are running
#istioctl1.6 install -y

echo "Make sure to install Istio 1.5.6 (ENTER to contine, CTRL+C to exit)"
read -s
#kubectl create ns dev-portal
#helm repo add istio-dev-portal https://storage.googleapis.com/istio-dev-portal-helm
#helm repo update
#helm install idp istio-dev-portal/istio-dev-portal -n dev-portal

#cat << EOF | kubectl apply -f-
#apiVersion: networking.istio.io/v1beta1
#kind: Gateway
#metadata:
#  labels:
#    release: istio
#  name: istio-ingressgateway
#  namespace: istio-system
#spec:
#  selector:
#    app: istio-ingressgateway
#    istio: ingressgateway
#  servers:
#  - hosts:
#    - '*'
#    port:
#      name: http
#      number: 80
#      protocol: HTTP
#EOF

install-idp

kubectl label namespace default istio-injection=enabled --overwrite
kubectl apply -f resources/petstore-classic-manifest.yaml
kubectl apply -f resources/petstore-special-manifest.yaml

VERSION=$(kubectl get deploy -n dev-portal admin-server -o yaml | grep admin-server | grep image | cut -d '/' -f 2)

kubectl apply -f resources/petstore-routes.yaml

echo "On istio-dev-portal version $VERSION"
