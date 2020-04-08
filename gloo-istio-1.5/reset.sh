kubectl delete vs default -n gloo-system
kubectl delete -f resources/productpage-upstream.yaml
kubectl apply -f resources/gateway-proxy-deploy.yaml
rm -f ./pcap/*.pcap