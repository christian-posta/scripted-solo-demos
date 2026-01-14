source .env

kubectl delete secret elicitation-oidc -n enterprise-agentgateway

kubectl create secret generic elicitation-oidc -n enterprise-agentgateway  --from-literal=client_id=$DATABRICKS_OAUTH_CLIENT_ID --from-literal=client_secret=$DATABRICKS_OAUTH_CLIENT_SECRET --from-literal=app_id=databricks --from-literal=scopes="genie mcp.genie offline_access" --from-literal=authorize_url=https://dbc-f1002050-7c6a.cloud.databricks.com/oidc/v1/authorize  --from-literal=access_token_url=https://dbc-f1002050-7c6a.cloud.databricks.com/oidc/v1/token --from-literal=redirect_uri=http://localhost:4000/age/elicitations  --dry-run=client -o yaml | kubectl apply  -f -


