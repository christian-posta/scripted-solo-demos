# Set up services

PID=$(ps aux | grep deployment/api-server | awk '{print $2}')
kill -9 $PID &> /dev/null
kubectl port-forward -n gloo-system deployment/api-server 8081:8080  &> /dev/null &  
echo "Gloo UI running on http://localhost:8081"

PID=$(ps aux | grep svc/admin-server | awk '{print $2}')
kill -9 $PID &> /dev/null
kubectl port-forward -n dev-portal svc/admin-server 8082:8080 &> /dev/null &
echo "Dev Portal running on http://localhost:8082"

kill -9 $(ps aux | grep port-forward | grep svc/dex | awk '{print $2}') &> /dev/null
kubectl -n gloo-system port-forward svc/dex 32000:32000  &> /dev/null &  
echo "Dex running on localhost:32000"

kill -9 $(ps aux | grep port-forward | grep svc/gateway-proxy | awk '{print $2}') &> /dev/null
kubectl -n gloo-system port-forward svc/gateway-proxy 8080:80  &> /dev/null &  
echo "Gateway Proxy running on localhost:8080"
