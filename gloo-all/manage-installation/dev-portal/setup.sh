DIR=$(dirname ${BASH_SOURCE})

source ~/bin/glooe-license-key-env 
cat << EOF > /tmp/dev-portal-values.yaml
gloo:
  enabled: true
licenseKey:
  secretRef:
    name: license
    namespace: gloo-system
    key: license-key
EOF

kubectl create namespace dev-portal
# previous was 0.4.13
helm install dev-portal dev-portal/dev-portal --version 0.5.0 --create-namespace -n dev-portal --values /tmp/dev-portal-values.yaml

DIR=$(dirname ${BASH_SOURCE})
$DIR/../../60-dev-portal/reset.sh