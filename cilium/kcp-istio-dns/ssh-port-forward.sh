USER=${1:-solo}
BOX=${2:-cilium}

# UI
ssh -L 12000:localhost:12000 -C -N -l $USER $BOX &
UI_PID="$!"

function cleanup {
  kill -9 $UI_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box cilium.... press CTRL-C to end script"
read -s