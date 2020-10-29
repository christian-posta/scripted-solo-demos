# Set up services
. ~/bin/create-aws-secret
kubectl apply -f resources/k8s
kubectl apply -f resources/gloo

# dex
kubectl apply -f resources/components/dex.yaml -n gloo-system

#consul 
kubectl apply -f resources/components/consul-1.6.2.yaml -n default

#cert manager
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

echo "sleeping 15s for cert manager"
sleep 15s

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

istioctl install -y