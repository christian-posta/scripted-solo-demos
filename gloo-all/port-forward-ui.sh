# Set up services

kubectl port-forward -n gloo-system deployment/api-server 8081:8080  &> /dev/null &  

echo "Gloo UI running on http://localhost:8081"