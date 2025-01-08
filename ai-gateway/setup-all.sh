

./setup-kind.sh

CONTEXT="${1:-ai-demo}"

kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# ./install-gateway-stable.sh $CONTEXT
./install-gateway-nightly.sh $CONTEXT

# create tokens here..
source ~/bin/ai-keys

#openai token
kubectl --context $CONTEXT create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -


kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml
