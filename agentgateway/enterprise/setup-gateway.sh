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

# Install supporting components
kubectl apply -f ./resources/setup/supporting.yaml
kubectl apply -f ./resources/setup/gateway.yaml

# Optional: dummy failover service (used by /failover/openai route demo)
kubectl apply -f ./resources/supporting/failover-429.yaml

