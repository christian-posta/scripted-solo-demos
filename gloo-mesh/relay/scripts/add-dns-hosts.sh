GLOO_IP_CLUSTER_1=$(kubectl --context gloo-mesh-1 get svc/gateway-proxy -n gloo-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
GLOO_IP_CLUSTER_2=$(kubectl --context gloo-mesh-2 get svc/gateway-proxy -n gloo-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo "$GLOO_IP_CLUSTER_1 web-api.mesh.ceposta.solo.io" | sudo tee -a /etc/hosts