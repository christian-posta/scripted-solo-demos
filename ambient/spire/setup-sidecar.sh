./setup-kind.sh

ISTIO_DIR=/home/solo/dev/istio/istio-1.23.0

# start with apps already installed; will apply istio after
kubectl apply -f sample-apps/

# install istio without ambient
istioctl install -y -f ./resources/istio/install.yaml

# add the observability sample components
kubectl apply -f $ISTIO_DIR/samples/addons/

