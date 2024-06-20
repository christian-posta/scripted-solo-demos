./setup-kind.sh

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

kubectl apply -f sample-apps/

# by default we will install WITHOUT ambient, 
istioctl install -y -f ./resources/istio/install.yaml

kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/

kubectl apply -f ./resources/hack/grafana-waypoint.yaml