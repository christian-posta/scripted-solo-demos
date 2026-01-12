source .env

# Get rid of this when the issue is fixed: https://github.com/solo-io/kagent-enterprise/issues/1026
./setup-hack-for-elicitation.sh

kubectl create secret generic elicitation-oidc -n enterprise-agentgateway  --from-literal=client_id=$GITHUB_CLIENT_ID --from-literal=app_id=2085885 --from-literal=client_secret=$GITHUB_CLIENT_SECRET --from-literal=authorize_url=https://github.com/login/oauth/authorize  --from-literal=access_token_url=https://github.com/login/oauth/access_token --from-literal=scopes=read:user --from-literal=redirect_uri=http://localhost:4000/age/elicitations  --dry-run=client -o yaml | kubectl apply  -f -


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



# Install AgentGateway UI which helps surface the elicitaitons
export KEYCLOAK_IP=34.23.181.61
export OIDC_BACKEND=kagent-backend
export OIDC_FRONTEND=kagent-ui
export BACKEND_CLIENT_SECRET=$KEYCLOAK_BACKEND_CLIENT_SECRET
export ENDPOINT=https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect
export authEndpoint=https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect/auth
export tokenEndpoint=https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect/token
export logoutEndpoint=https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect/logout
export OIDC_ISSUER=https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev
export KAGENT_ENT_VERSION=0.1.10-2026-01-06-main-ba15b13f

helm upgrade -i kagent-mgmt \
oci://us-docker.pkg.dev/developers-369321/solo-enterprise-public-nonprod/charts/management \
-n kagent --create-namespace \
--version $KAGENT_ENT_VERSION \
-f - <<EOF
imagePullSecrets: []
global:
  imagePullPolicy: IfNotPresent
oidc:
  issuer: ${OIDC_ISSUER}
rbac:
  roleMapping:
    roleMapper: "claims.Groups.transformList(i, v, v in rolesMap, rolesMap[v])"
    roleMappings:
      admins: "global.Admin"
      readers: "global.Reader"
      writers: "global.Writer"
service:
  type: LoadBalancer
  clusterIP: ""
ui:
  backend:
    oidc:
      clientId: ${OIDC_BACKEND}
      secret: ${BACKEND_CLIENT_SECRET}
  frontend:
    oidc:
      clientId: ${OIDC_FRONTEND}
clickhouse:
  enabled: true
tracing:
  verbose: true
EOF


kubectl apply -f ./resources/elicitation/httpbin.yaml