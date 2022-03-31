# UI
ssh -L 8090:localhost:8090 -C -N -l solo gmv2&
UI_PID="$!"

# Gogs
ssh -L 3000:localhost:3000 -C -N -l solo gmv2&
GOGS_PID="$!"

# Argo
ssh -L 8088:localhost:8088 -C -N -l solo gmv2&
ARGO_PID="$!"

# Bookinfo
ssh -L 8443:172.18.2.1:443 -C -N -l solo gmv2&
BOOK_PID="$!"

function cleanup {
  kill -9 $UI_PID
  kill -9 $GOGS_PID
  kill -9 $ARGO_PID
  kill -9 $BOOK_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box gmv2.... press ENTER to end script"
read -s
