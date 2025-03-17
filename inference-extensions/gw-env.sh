export IP=$(kubectl get gateway/inference-gateway -o jsonpath='{.status.addresses[0].value}')
export PORT=8081


export DIRECT_IP=$(kubectl get svc/my-pool-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export DIRECT_PORT=8000

