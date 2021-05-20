
MGMT_INGRESS_ADDRESS=$(kubectl --context $MGMT_CONTEXT get svc -n gloo-mesh enterprise-networking -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
RELAY_ADDRESS=${MGMT_INGRESS_ADDRESS}:9900
