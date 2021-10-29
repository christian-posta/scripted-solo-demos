#!/bin/bash
SOURCE_DIR=$PWD
source ./env.sh


## Set up vault on management plane


  # For more info on vault in kubernetes, please see: https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager

  # install vault in dev mode
  helm install -n vault  vault hashicorp/vault --set "injector.enabled=false" --set "server.dev.enabled=true" --kube-context=$MGMT_CONTEXT --create-namespace

  # Wait for vault to come up, can't use kubectl rollout because it's a stateful set without rolling deployment
  kubectl --context=$MGMT_CONTEXT wait --for=condition=Ready -n vault pod/vault-0

  #sleep anyway
  echo "Sleeping 5s..."
  sleep 5s

  # Enable vault kubernetes Auth
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault auth enable kubernetes'

  # Set the kubernetes Auth config for vault to the mounted token
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'

  # Bind the istiod service account to the pki policy below
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/role/gen-int-ca-istio \
    bound_service_account_names=istiod-service-account \
    bound_service_account_namespaces=istio-system \
    policies=gen-int-ca-istio \
    ttl=2400h'

  # Initialize vault PKI
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable pki'

  # set the vault CA to our pem_bundle
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c "vault write -format=json pki/config/ca pem_bundle=\"$(cat ./resources/vault/root-key.pem ./resources/vault/root-cert.pem)\""

  # Initialize vault intermediate path
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable -path pki_int pki'

  # Set the policy for intermediate cert path
  kubectl --context=$MGMT_CONTEXT exec -n vault vault-0 -- /bin/sh -c 'vault policy write gen-int-ca-istio - <<EOF
path "pki_int/*" {
capabilities = ["create", "read", "update", "delete", "list"]
}
path "pki/cert/ca" {
capabilities = ["read"]
}
path "pki/root/sign-intermediate" {
capabilities = ["create", "read", "update", "list"]
}
EOF'