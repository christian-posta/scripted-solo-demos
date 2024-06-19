./setup-kind.sh

kubectl apply -f sample-apps/

istioctl install -y -f ./istio/tracing-install.yaml 

kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/