kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

until [ $(kubectl get pods -n cert-manager -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the cert-manager namespace to become ready"
  sleep 1
done


cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging-http01
  namespace: gloo-system
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ceposta@solo.io
    privateKeySecretRef:
      name: letsencrypt-staging-http01
    solvers:
    - http01:
        ingress:
          serviceType: ClusterIP
      selector:
        dnsNames:
        - $(glooctl proxy address | cut -f 1 -d ':').nip.io
EOF

cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: nip-io
  namespace: default
spec:
  secretName: nip-io-tls
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging-http01
  commonName: $(glooctl proxy address | cut -f 1 -d ':').nip.io
  dnsNames:
    - $(glooctl proxy address | cut -f 1 -d ':').nip.io
EOF

# Sleep for gloo to discover this upstream
sleep 5s

UPSTREAM_NAME=$(kubectl get upstream -n gloo-system | grep acme-http-solver | awk '{print $1}')

echo "Upstream name for acme http solver: $UPSTREAM_NAME"


ORDER_NAME=$(kubectl get orders.acme.cert-manager.io | grep nip | awk '{print $1}')
echo "Order name: $ORDER_NAME"

TOKEN_NAME=$(kubectl get orders.acme.cert-manager.io $ORDER_NAME -o=jsonpath='{.status.authorizations[0].challenges[?(@.type=="http-01")].token}')

# create vs
cat << EOF | kubectl apply -f -
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: letsencrypt
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - $(glooctl proxy address | cut -f 1 -d ':').nip.io
    routes:
    - matchers:
      - exact: /.well-known/acme-challenge/$TOKEN_NAME
      routeAction:
        single:
          upstream:
            name: $UPSTREAM_NAME
            namespace: gloo-system
EOF

echo "Waiting 5s for order to complete"
sleep 5s

until [ $(kubectl get -n default certificates.cert-manager.io -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the cert-manager namespace to become ready"
  sleep 1
done

echo "Getting certs"
kubectl get -n default certificates.cert-manager.io -w


echo "After things turn to true, we should delete the letsencrypt vs"

kubectl delete -n gloo-system virtualservice letsencrypt



