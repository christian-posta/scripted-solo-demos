# Install Istio
kubectl apply -f resources/istio-1.4-auth-sds.yaml

# Install Bookinfo
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled --overwrite
kubectl apply -n bookinfo -f resources/bookinfo.yaml 

# Install Gloo
glooctl install gateway

