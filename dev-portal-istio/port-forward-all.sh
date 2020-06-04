echo "Stopping all kubectl portforward..."
kubectl port-forward svc/dev-portal -n dev-portal 1234:8080 &> /dev/null & 
echo "Dev Portal on port 1234"
kubectl port-forward deploy/admin-server -n dev-portal 8090:8090 &> /dev/null &
echo "UI on port 8090"
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 &> /dev/null &
echo "Istio IngressGateway on port 8080"
