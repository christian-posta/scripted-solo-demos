kubectl delete meshpolicy --all -n default
kubectl delete destinationrule -n istio-system   example-service1-calc-svc-cluster-local 
kubectl delete destinationrule -n istio-system   example-service2-calc-svc-cluster-local 
