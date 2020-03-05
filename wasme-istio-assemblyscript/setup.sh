# Install Istio
kubectl create ns istio-system
kubectl apply -f resources/istio-1.5.yaml

# Install Bookinfo
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled --overwrite
kubectl apply -n bookinfo -f resources/bookinfo.yaml 
