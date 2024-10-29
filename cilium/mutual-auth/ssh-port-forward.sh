USER=${1:-solo}
BOX=${2:-cilium}

# UI
ssh -L 12000:localhost:12000 -C -N -l $USER $BOX &
UI_PID="$!"

#Kiali
ssh -L 20001:localhost:20001 -C -N -l $USER $BOX &
KIALI_PID="$!"

function cleanup {
  kill -9 $UI_PID
  kill -9 $KIALI_PID
}

trap cleanup EXIT

echo "Port forwarding to remote box cilium.... press CTRL-C to end script"
read -s
