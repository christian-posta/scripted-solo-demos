VERSION=${1:-latest}
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo "The script is located in: $SCRIPT_DIR"
docker run -it -p 3000:3000 -v $SCRIPT_DIR/config.json:/app/config.json ghcr.io/mcp-proxy/mcp-proxy:${VERSION} -f /app/config.json
