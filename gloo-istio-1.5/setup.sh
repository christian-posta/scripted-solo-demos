# Install Istio
#istioctl manifest apply --set profile=minimal
echo "Make sure to install Istio 1.5.6 (ENTER to contine, CTRL+C to exit)"
read -s

# Install Bookinfo
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled --overwrite
kubectl apply -n bookinfo -f resources/bookinfo.yaml 

# Install Gloo
#glooctl install gateway