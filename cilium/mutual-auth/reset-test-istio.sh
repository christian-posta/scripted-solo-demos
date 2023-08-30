#!/bin/bash
# Note: the content in this file is a subset from test.sh 
# Find the all the IPs of sleep-v1:

NODEV1=$(kubectl get pod -l app=helloworld,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')
API_SERVER=$(kubectl get service -n default kubernetes -o=jsonpath='{.spec.clusterIP}')
API_SERVEREP=$(kubectl get endpoints -n default kubernetes -o jsonpath='{.subsets[0].addresses[0].ip}')
docker exec $NODEV1 iptables -t mangle -D INPUT -p tcp -s $API_SERVER -j DROP
docker exec $NODEV1 iptables -t mangle -D INPUT -p tcp -s $API_SERVEREP -j DROP

kubectl label namespace default istio-injection-

kubectl rollout restart deployment/helloworld-v1
kubectl rollout restart deployment/helloworld-v2


# scale sleep-v1 to 0
kubectl scale deploy sleep-v1 --replicas=15
kubectl scale deploy sleep-v2 --replicas=1