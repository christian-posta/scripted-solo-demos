

# install dex
kubectl apply -f dex.yaml -n gloo-system

kubectl get po -n gloo-system -w

# Install default gateway
kubectl apply -f default-vs.yaml



# Create secret
glooctl create secret oauth --client-secret secretvalue oauth

kubectl -n gloo-system port-forward svc/dex 32000:32000  &> /dev/null &  
kubectl -n gloo-system port-forward svc/gateway-proxy 8080:80  &> /dev/null &  


# Don't run anything past here
exit 0

ADDRESS=$(glooctl proxy address)
cat << EOF | kubectl apply -f -
apiVersion: enterprise.gloo.solo.io/v1
kind: AuthConfig
metadata:
  name: oidc-dex
  namespace: gloo-system
spec:
  configs:
  - oauth:
      app_url: http://$ADDRESS/
      callback_path: /callback
      client_id: gloo
      client_secret_ref:
        name: oauth
        namespace: gloo-system
      issuer_url: http://dex.gloo-system.svc.cluster.local:32000/
      scopes:
      - email
EOF



# Source: dex/templates/secret.yaml
cat << EOF | kubectl -n gloo-system apply -f -
apiVersion: v1
kind: Secret
metadata:
  labels:
    app.kubernetes.io/name: dex
    helm.sh/chart: dex-2.9.0
    app.kubernetes.io/instance: dex
    app.kubernetes.io/version: "2.21.0"
    app.kubernetes.io/managed-by: Tiller
  name: dex
stringData:
  config.yaml: |-
    issuer: http://dex.gloo-system.svc.cluster.local:32000
    storage:
      config:
        inCluster: true
      type: kubernetes
      
    logger:
      level: debug
      
    web:
      http: 0.0.0.0:5556
    grpc:
      addr: 127.0.0.1:5000
      tlsCert: /etc/dex/tls/grpc/server/tls.crt
      tlsKey: /etc/dex/tls/grpc/server/tls.key
      tlsClientCA: /etc/dex/tls/grpc/ca/tls.crt
    oauth2: 
      alwaysShowLoginScreen: false
      skipApprovalScreen: true
      
    staticClients:
    - id: gloo
      name: GlooApp
      redirectURIs:
      - http://$ADDRESS/callback
      secret: secretvalue
    
    enablePasswordDB: true
    staticPasswords:
    - email: admin@example.com
      hash: \$2a\$10\$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W
      userID: 08a8684b-db88-4b73-90a9-3cd1661f5466
      username: admin
    - email: "user@example.com"
      hash: "\$2a\$10\$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
      userID: "123456789-db88-4b73-90a9-3cd1661f5466"
      username: "user"
EOF

# install dex
kubectl apply -f dex.yaml -n gloo-system