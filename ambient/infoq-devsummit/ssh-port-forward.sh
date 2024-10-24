USER=${1:-solo}
BOX=${2:-amb}


# Grafana
ssh -L 3000:localhost:3000 -C -N -l $USER $BOX &
GRAFANA_PID="$!"

# Gateway
#ssh -L 8080:172.18.101.1:8080 -C -N -l $USER $BOX &
#GW_PID="$!"

#Kiali
ssh -L 20001:localhost:20001 -C -N -l $USER $BOX &
KIALI_PID="$!"

#Kiali
ssh -L 16686:localhost:16686 -C -N -l $USER $BOX &
JAEGER_PID="$!"

#Prom
ssh -L 9090:localhost:9090 -C -N -l $USER $BOX &
PROM_PID="$!"

function cleanup {
  kill -9 $GRAFANA_PID
  kill -9 $KIALI_PID
  kill -9 $JAEGER_PID
  #kill -9 $GW_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box amb.... press CTRL-C to end script"
read -s
