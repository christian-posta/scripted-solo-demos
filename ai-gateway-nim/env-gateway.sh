export INGRESS_GW_ADDRESS1=$(kubectl --context $CLUSTER1 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

export INGRESS_GW_ADDRESS2=$(kubectl --context $CLUSTER2 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

echo "AI Gateway (Cluster 1) endpoint INGRESS_GW_ADDRESS1: $INGRESS_GW_ADDRESS1"
echo "AI Gateway (Cluster 2) endpoint INGRESS_GW_ADDRESS2: $INGRESS_GW_ADDRESS2"