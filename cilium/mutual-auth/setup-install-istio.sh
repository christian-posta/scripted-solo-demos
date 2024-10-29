export TAG=1.23.2-patch1-solo
istioctl install -y -f ./istio/operator.yaml 
kubectl apply -f /home/solo/dev/istio/istio-1.23.2-patch1-solo/samples/addons/