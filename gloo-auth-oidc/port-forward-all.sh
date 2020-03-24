#!/bin/bash
killall kubectl 


kubectl -n gloo-system port-forward svc/dex 32000:32000  &> /dev/null &  

echo "Petclinic: http://localhost:8080"
kubectl -n gloo-system port-forward svc/gateway-proxy 8080:80  &> /dev/null &  

echo "Admin Console: http://localhost:8081"
kubectl port-forward -n gloo-system deployment/api-server 8081:8080  &> /dev/null &  