USER=${1:-solo}
BOX=${2:-gmv2}


GRAFANA_IP=$(ssh $USER@$BOX "kubectl get svc kube-prometheus-stack-grafana  -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

GW_IP=$(ssh $USER@$BOX "kubectl get svc gloo-proxy-ai-gateway  -n gloo-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

JAEGER_IP=$(ssh $USER@$BOX "kubectl get svc jaeger-loadbalancer -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

# Gateway
ssh -L 8080:$GW_IP:8080 -C -N -l $USER $BOX &
GW_PID="$!"

ssh -L 6001:localhost:6001 -C -N -l $USER $BOX &
UI_SERVER_PID="$!"

ssh -L 3000:$GRAFANA_IP:3000 -C -N -l $USER $BOX &
GRAF_PID="$!"

ssh -L 16686:$JAEGER_IP:16686 -C -N -l $USER $BOX &
JAEGER_PID="$!"

function cleanup {

  kill -9 $GW_PID
  kill -9 $UI_SERVER_PID
  kill -9 $GRAF_PID
  kill -9 $JAEGER_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box gmv2.... press CTRL-C to end script"
read -s
