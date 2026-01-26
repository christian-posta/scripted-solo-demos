source .env

kubectl delete secret elicitation-oidc -n enterprise-agentgateway

kubectl create secret generic elicitation-oidc -n enterprise-agentgateway  --from-literal=client_id=$DATABRICKS_OAUTH_CLIENT_ID --from-literal=client_secret=$DATABRICKS_OAUTH_CLIENT_SECRET --from-literal=app_id=databricks --from-literal=scopes="genie mcp.genie offline_access" --from-literal=authorize_url=https://dbc-f1002050-7c6a.cloud.databricks.com/oidc/v1/authorize  --from-literal=access_token_url=https://dbc-f1002050-7c6a.cloud.databricks.com/oidc/v1/token --from-literal=redirect_uri=http://localhost:4000/age/elicitations  --dry-run=client -o yaml | kubectl apply  -f -


helm upgrade -i -n enterprise-agentgateway enterprise-agentgateway oci://us-docker.pkg.dev/solo-public/enterprise-agentgateway/charts/enterprise-agentgateway \
--reuse-values \
--version $ENTERPRISE_AGW_VERSION \
--set-string licensing.licenseKey=$AGENTGATEWAY_LICENSE \
-f -<<EOF
tokenExchange:
  enabled: true
  issuer: "enterprise-agentgateway.enterprise-agentgateway.svc.cluster.local:7777"
  tokenExpiration: 24h
  oidc:
    secretName: "elicitation-oidc"
  subjectValidator:
    validatorType: remote
    remoteConfig:
      url: "https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect/certs"
  actorValidator:
    validatorType: k8s
EOF