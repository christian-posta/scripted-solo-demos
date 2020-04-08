# Install Istio
istioctl manifest apply --set profile=minimal

# Install Bookinfo
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled --overwrite
kubectl apply -n bookinfo -f resources/bookinfo.yaml 

# Install Gloo
glooctl install gateway