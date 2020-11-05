DIR=$(dirname ${BASH_SOURCE})
#########
#cert manager - lave to last step
#########
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

echo "sleeping 15s for cert manager"
sleep 10s

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

kubectl rollout status deployment cert-manager -n cert-manager
kubectl rollout status deployment cert-manager-cainjector -n cert-manager
kubectl rollout status deployment cert-manager-webhook -n cert-manager

## set up cluster issuer and then prepare the certs
cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging-http01
  namespace: gloo-system
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ceposta@solo.io
    privateKeySecretRef:
      name: letsencrypt-staging-http01
    solvers:
    - http01:
        ingress:
          serviceType: ClusterIP
      selector:
        dnsNames:
          - ceposta-gloo-demo.solo.io
          - ceposta-auth-demo.solo.io
          - ceposta-apis-demo.solo.io
EOF