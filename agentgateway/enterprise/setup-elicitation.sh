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



kubectl apply -f ./resources/elicitation/httpbin.yaml