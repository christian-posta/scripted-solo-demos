# When this gets fixed, we can deldete this: https://github.com/solo-io/kagent-enterprise/issues/1026

kubectl create namespace agentgateway-system

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: enterprise-agentgateway            # hardcoded name expected by components
  namespace: agentgateway-system           # hardcoded namespace
  labels:
    app: enterprise-agentgateway-shadow
spec:
  clusterIP: None                          # headless
  ports:
    - name: grpc-xds-agw
      port: 9978
      protocol: TCP
    - name: health
      port: 9093
      protocol: TCP
    - name: token-exchange
      port: 7777
      protocol: TCP
EOF

# Get the pod IPs from enterprise-agentgateway deployment
echo "Looking up pod IPs for enterprise-agentgateway..."
POD_IPS=$(kubectl get pods -n enterprise-agentgateway -l app.kubernetes.io/name=enterprise-agentgateway -o jsonpath='{.items[*].status.podIP}')

if [ -z "$POD_IPS" ]; then
  echo "ERROR: No pods found for enterprise-agentgateway. Make sure the deployment exists."
  exit 1
fi

# Build the addresses array dynamically
ADDRESSES=""
for ip in $POD_IPS; do
  ADDRESSES="${ADDRESSES}      - ip: ${ip}
"
done

echo "Found pod IPs: $POD_IPS"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  name: enterprise-agentgateway            # must match Service name
  namespace: agentgateway-system           # must match Service namespace
subsets:
  - addresses:
${ADDRESSES}    ports:
      - name: grpc-xds-agw
        port: 9978
        protocol: TCP
      - name: health
        port: 9093
        protocol: TCP
      - name: token-exchange
        port: 7777
        protocol: TCP
EOF

echo "Endpoints created successfully!"
