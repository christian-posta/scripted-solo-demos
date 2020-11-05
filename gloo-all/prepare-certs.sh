echo "preparing certs"

NAME=${1:-"ceposta-gloo-demo"}
DOMAIN="$NAME.solo.io"

echo "Naming things $NAME"
echo "For Domain: $DOMAIN"
echo "Press <ENTER> to continue"
read -s

cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: $NAME
  namespace: gloo-system
spec:
  secretName: $NAME-dns
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging-http01
  dnsNames:
    - $DOMAIN
EOF

echo "Watch acme svc to be created"
kubectl get svc -n gloo-system -w

UPSTREAM_NAME=$(kubectl get upstream -n gloo-system | grep cm-acme-http-solver | awk '{print $1}')
echo "Upstream name for acme http solver: $UPSTREAM_NAME"

ORDER_NAME=$(kubectl get orders.acme.cert-manager.io -n gloo-system | grep $NAME | awk '{print $1}')
echo "Order name: $ORDER_NAME"
TOKEN_NAME=$(kubectl get orders.acme.cert-manager.io -n gloo-system $ORDER_NAME -o=jsonpath='{.status.authorizations[0].challenges[?(@.type=="http-01")].token}')

if [ -z "$UPSTREAM_NAME" ]
then
    echo "Skipping $DOMAIN"
else
    echo "Creating VS for $DOMAIN"
    # create vs
cat << EOF | kubectl apply -f -
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: letsencrypt-$NAME
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - $DOMAIN
    routes:
    - matchers:
      - exact: /.well-known/acme-challenge/$TOKEN_NAME
      routeAction:
        single:
          upstream:
            name: $UPSTREAM_NAME
            namespace: gloo-system
EOF
fi

echo "Waiting for cert to be ready"
kubectl get -n gloo-system certificates.cert-manager.io -w

echo "Deleting virtualservice"
kubectl delete -n gloo-system virtualservice letsencrypt-$NAME




