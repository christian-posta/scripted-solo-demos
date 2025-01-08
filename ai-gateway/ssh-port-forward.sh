USER=${1:-solo}
BOX=${2:-gmv2}


GRAFANA_IP=$(ssh $USER@$BOX "kubectl get svc kube-prometheus-stack-grafana  -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

GW_IP=$(ssh $USER@$BOX "kubectl get svc gloo-proxy-ai-gateway  -n gloo-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

# Gateway
ssh -L 8080:$GW_IP:8080 -C -N -l $USER $BOX &
GW_PID="$!"

ssh -L 3000:$GRAFANA_IP:3000 -C -N -l $USER $BOX &
GRAF_PID="$!"

function cleanup {

  kill -9 $GW_PID
  kill -9 $GRAF_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box amb.... press CTRL-C to end script"
read -s
