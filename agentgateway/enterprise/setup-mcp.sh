source .env


kubectl apply -f ./resources/mcp/public.yaml
kubectl apply -f ./resources/mcp/jwt-secure.yaml
kubectl apply -f ./resources/mcp/public-oauth.yaml
kubectl apply -f ./resources/mcp/mcp-oidc.yaml

