USER=${1:-solo}
BOX=${2:-gmv2}

# UI
ssh -L 8090:localhost:8090 -C -N -l $USER $BOX &
UI_PID="$!"

function cleanup {
  kill -9 $UI_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box gmv2.... press CTRL-C to end script"
read -s
