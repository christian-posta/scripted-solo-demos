source .env

kubectl delete secret elicitation-oidc -n enterprise-agentgateway

kubectl create secret generic elicitation-oidc -n enterprise-agentgateway  --from-literal=client_id=$FIGMA_OAUTH_CLIENT_ID --from-literal=authorize_url=https://www.figma.com/oauth/mcp  --from-literal=access_token_url=https://api.figma.com/v1/oauth/token --from-literal=scopes=mcp:connect --from-literal=redirect_uri=http://localhost:33418  --dry-run=client -o yaml | kubectl apply  -f -


