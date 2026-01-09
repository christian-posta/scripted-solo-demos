# Export all variables from .env so envsubst can see them
set -a
source .env
set +a

# Use envsubst to substitute environment variables (like $AUTH0_CLIENT_SECRET) in the YAML
envsubst < ./resources/mcp/mcp-oidc-extauth.yaml | kubectl apply -f -
