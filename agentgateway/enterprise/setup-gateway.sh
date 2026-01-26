# pick up local env variables
source .env

# Create namespace
kubectl create namespace enterprise-agentgateway

# Install Gateway API
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

# Install CRDs
helm upgrade -i --create-namespace --namespace enterprise-agentgateway \
    --version $ENTERPRISE_AGW_VERSION enterprise-agentgateway-crds \
    oci://us-docker.pkg.dev/solo-public/enterprise-agentgateway/charts/enterprise-agentgateway-crds


# Install controller / control plane
helm upgrade -i -n enterprise-agentgateway enterprise-agentgateway oci://us-docker.pkg.dev/solo-public/enterprise-agentgateway/charts/enterprise-agentgateway \
--create-namespace \
--version $ENTERPRISE_AGW_VERSION \
--set-string licensing.licenseKey=$AGENTGATEWAY_LICENSE \
-f -<<EOF
image:
  registry: us-docker.pkg.dev/solo-public/enterprise-agentgateway
  tag: "$ENTERPRISE_AGW_VERSION"
  pullPolicy: IfNotPresent
gatewayClassParametersRefs:
  enterprise-agentgateway:
    group: enterpriseagentgateway.solo.io
    kind: EnterpriseAgentgatewayParameters
    name: agentgateway-params
    namespace: enterprise-agentgateway
EOF


# Can later get values from the installation with this:

# helm get values enterprise-agentgateway -n enterprise-agentgateway  

# Install supporting components
kubectl apply -f ./resources/setup/supporting.yaml
kubectl apply -f ./resources/setup/gateway.yaml

# Optional: dummy failover service (used by /failover/openai route demo)
kubectl apply -f ./resources/supporting/failover-429.yaml



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
# export KAGENT_ENT_VERSION=0.1.10-2026-01-06-main-ba15b13f

# export KAGENT_MGMT_CHART=oci://us-docker.pkg.dev/developers-369321/solo-enterprise-public-nonprod/charts/management
export KAGENT_ENT_VERSION=0.2.1
export KAGENT_MGMT_CHART=oci://us-docker.pkg.dev/solo-public/solo-enterprise-helm/charts/management

helm upgrade -i kagent-mgmt \
 $KAGENT_MGMT_CHART \
-n kagent --create-namespace \
--version "$KAGENT_ENT_VERSION" \
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