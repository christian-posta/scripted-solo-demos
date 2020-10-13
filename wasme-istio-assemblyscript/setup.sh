# Install Istio
kubectl create ns istio-system
kubectl apply -f resources/istio-1.5.yaml


echo "Wait for Istio"
kubectl get po -n istio-system -w

# Install Bookinfo
kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled --overwrite
kubectl apply -n bookinfo -f resources/bookinfo.yaml 

#Install Wasme Operator
kubectl apply -f resources/wasme-crds.yaml
kubectl apply -f resources/wasme-operator.yaml
