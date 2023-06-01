USER=${1:-solo}
BOX=${2:-gmv2}

# UI
ssh -L 8090:localhost:8090 -C -N -l $USER $BOX &
UI_PID="$!"

ssh -L 8091:localhost:8091 -C -N -l $USER $BOX &
UI2_PID="$!"

# Gogs
ssh -L 3000:localhost:3000 -C -N -l $USER $BOX &
GOGS_PID="$!"

# Argo
ssh -L 8088:localhost:8088 -C -N -l $USER $BOX &
ARGO_PID="$!"

# Bookinfo
ssh -L 8443:172.18.102.1:443 -C -N -l $USER $BOX &
BOOK_PID="$!"

#Kiali
ssh -L 20001:localhost:20001 -C -N -l $USER $BOX &
KIALI_PID="$!"

function cleanup {
  kill -9 $UI_PID
  kill -9 $UI2_PID  
  kill -9 $GOGS_PID
  kill -9 $ARGO_PID
  kill -9 $BOOK_PID
  kill -9 $KIALI_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box gmv2.... press CTRL-C to end script"
read -s
