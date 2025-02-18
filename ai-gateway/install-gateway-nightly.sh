CONTEXT="${1:-ai-demo}"

if [[ "$2" != "skip" ]]; then
  echo "Using kube context: $CONTEXT"
  read -p "Press Enter to continue..."
fi


kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

helm repo add gloo-ee-test https://storage.googleapis.com/gloo-ee-test-helm
helm repo update

# VERSION="1.19.0-beta1-bmain-f7062f9"
VERSION="1.19.0-beta3-bmain-70beacc"
# VERSION="1.19.0-beta3-bstevenctlwaypoint-cidr-ipv-6218fe9"


source ~/bin/glooe-license-key-env 
helm upgrade --kube-context $CONTEXT -i gloo-gateway gloo-ee-test/gloo-ee \
  --version $VERSION \
  --namespace gloo-system --create-namespace \
  --set license_key=$GLOO_LICENSE_WITH_AI \
-f ./gloo-gateway-values.yaml


kubectl --context $CONTEXT apply -f ./resources/ai-gateway.yaml
