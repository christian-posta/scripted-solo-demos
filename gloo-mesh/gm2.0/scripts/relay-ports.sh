
MGMT_INGRESS_ADDRESS=$(kubectl --context $MGMT get svc -n gloo-mesh gloo-mesh-mgmt-server -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
RELAY_ADDRESS=${MGMT_INGRESS_ADDRESS}:9900

