USER=${1:-solo}
BOX=${2:-gmv2}


# Gateway
ssh -L 8080:172.18.101.1:8080 -C -N -l $USER $BOX &
GW_PID="$!"

function cleanup {

  kill -9 $GW_PID
}

trap cleanup EXIT


echo "Port forwarding to remote box amb.... press CTRL-C to end script"
read -s
