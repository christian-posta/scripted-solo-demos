CONTEXT="${1:-gke-nim2}"


# consider updating to newer Gateway CRDs
# kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


source ~/bin/glooe-license-key-env 
helm repo add gloo-ee-test https://storage.googleapis.com/gloo-ee-test-helm
helm repo update

helm upgrade --kube-context $CONTEXT --install -n gloo-system gloo-ee-test gloo-ee-test/gloo-ee --create-namespace --version 1.18.0-beta2-beitanyaai-passthrough-token-006f8e6 --set-string license_key=$GLOO_LICENSE_KEY --set gloo-fed.enabled=false --set gloo-fed.glooFedApiserver.enable=false --set gloo.kubeGateway.enabled=true --set gloo.gatewayProxies.gatewayProxy.disabled=true


# create tokens here..
source ~/bin/ai-keys

#openai token
kubectl --context $CONTEXT create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

#mistral token
kubectl --context $CONTEXT create secret generic mistralai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $MISTRAL_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -


kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml