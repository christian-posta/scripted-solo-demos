#!/bin/bash
echo "http://localhost:8081"
kubectl port-forward -n gloo-system deployment/api-server 8081:8080  &> /dev/null &  

