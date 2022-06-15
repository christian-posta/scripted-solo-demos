USER=${1:-solo}
BOX=${2:-workshop}

# UI
ssh -L 8090:localhost:8090 -C -N -l $USER $BOX &
UI_PID="$!"

# Gogs
ssh -L 3000:localhost:3000 -C -N -l $USER $BOX &
GOGS_PID="$!"

# Argo
ssh -L 8088:localhost:8088 -C -N -l $USER $BOX &
ARGO_PID="$!"

# Bookinfo
ssh -L 8080:172.18.2.1:80 -C -N -l $USER $BOX &
BOOK_PID="$!"

function cleanup {
  kill -9 $UI_PID
  kill -9 $GOGS_PID
  kill -9 $ARGO_PID
  kill -9 $BOOK_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box gmv2.... press CTRL-C to end script"
read -s
