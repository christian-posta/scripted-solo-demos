./setup-kind.sh

kubectl apply -f sample-apps/

# need gateway 1.0 crds
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


# install istio 
#istioctl install -y -f ./resources/istio/install.yaml --set profile=ambient