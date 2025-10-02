

if [ -n "$1" ]; then
  CONTEXT="$1"
else
  CONTEXT=$(kubectl config current-context)
fi

./install-gateway-stable.sh $CONTEXT "skip"

# create tokens here..
source ~/bin/ai-keys

#openai token
kubectl --context $CONTEXT create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -


# ./setup-observability.sh $CONTEXT

# Set up Local LLM
# kubectl --context $CONTEXT apply -f resources/extensions/ollama.yaml
# kubectl --context $CONTEXT apply -f ./resources/extensions/load-generator.yaml

