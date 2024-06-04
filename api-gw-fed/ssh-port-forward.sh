USER=${1:-solo}
BOX=${2:-amb}

# UI
ssh -L 3000:localhost:3000 -C -N -l $USER $BOX &
UI_PID="$!"


#Kiali
ssh -L 20001:localhost:20001 -C -N -l $USER $BOX &
KIALI_PID="$!"

function cleanup {
  kill -9 $UI_PID
  kill -9 $KIALI_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box amb.... press CTRL-C to end script"
read -s
