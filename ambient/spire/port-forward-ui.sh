

# Grafana port 3000
istioctl dashboard grafana &
GRAFANA_PID="$!"

# Kiali port 20001
istioctl dashboard kiali &
KIALI_PID="$!"

# Jaever port 16686
istioctl dashboard jaeger &
JAEGER_PID="$!"

# Jaever port 9090
istioctl dashboard prometheus &
PROM_PID="$!"

function cleanup {
  kill -9 $GRAFANA_PID
  kill -9 $KIALI_PID
  kill -9 $JAEGER_PID
  kill -9 $PROM_PID
}

trap cleanup EXIT


echo "Port forwarding dashboards.... press CTRL-C to end script"
read -s