
DEFAULT_CONFIG="resources/basic.yaml"

IMAGE="ghcr.io/agentgateway/agentgateway:0.6.2-ext"

CONFIG_LOCATION=${1:-$DEFAULT_CONFIG}
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "The script is located in: $SCRIPT_DIR"
docker run -it -e "RUST_BACKTRACE=full" -e "RUST_BACKTRACE=1" -p 5555:5555 -p 15020:15020 -p 3000:3000 -p 15000:15000 -v $SCRIPT_DIR/resources:/app/resources $IMAGE -f /app/${CONFIG_LOCATION}
