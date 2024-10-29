./setup-kind.sh

kubectl apply -f sample-apps/

# need gateway 1.0 crds
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


# install istio 
istioctl install -y -f ./resources/istio/install.yaml --set profile=ambient

kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/

# need this so we can select "waypoint" reporter on grafana
kubectl apply -f ./resources/hack/grafana-waypoint.yaml