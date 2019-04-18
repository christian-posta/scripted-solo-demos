supergloo init
kubectl label --overwrite namespace default istio-injection=enabled 
kubectl get pod -n supergloo-system -w