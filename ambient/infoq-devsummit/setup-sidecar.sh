./setup-kind.sh

# start with apps already installed; will apply istio after
kubectl apply -f sample-apps/

# install istio without ambient
istioctl install -y -f ./resources/istio/install.yaml

# add the observability sample components
kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/

