DEFAULT_CONFIG="examples/basic/config.json"
CONFIG_LOCATION=${1:-$DEFAULT_CONFIG}
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo "The script is located in: $SCRIPT_DIR"
docker run -it -e "RUST_BACKTRACE=full" -e "RUST_BACKTRACE=1" -p 3000:3000 -v $SCRIPT_DIR/examples:/app/examples mcp-proxy-demo -f /app/${CONFIG_LOCATION}
