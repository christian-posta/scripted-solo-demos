kubectl create ns smi-demo
kubectl label namespace smi-demo istio-injection=enabled
kubectl -n smi-demo apply -f resources/00-bookinfo-setup.yaml
kubectl -n smi-demo apply -f resources/01-deploy-v1.yaml
echo "http://$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/productpage"