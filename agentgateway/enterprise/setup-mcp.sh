set -a
source .env
set +a


kubectl apply -f ./resources/mcp/public.yaml
kubectl apply -f ./resources/mcp/jwt-secure.yaml
kubectl apply -f ./resources/mcp/public-oauth.yaml
kubectl apply -f ./resources/mcp/mcp-oidc.yaml

# Use envsubst to substitute environment variables (like $AUTH0_CLIENT_SECRET) in the YAML
envsubst < ./resources/mcp/mcp-oidc-extauth.yaml | kubectl apply -f -

envsubst < ./resources/mcp/public-oauth-entra.yaml | kubectl apply -f -