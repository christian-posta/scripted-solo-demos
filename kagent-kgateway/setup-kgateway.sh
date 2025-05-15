source env.sh
source ~/bin/ai-keys

kubectl apply -f resources/gateway.yaml

kubectl --context $CONTEXT create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

# Set up OpenAI secret for kgateway
kubectl create secret generic openai-secret -n kgateway-system --from-literal=Authorization=$OPENAI_API_KEY 
kubectl label secret openai-secret -n kgateway-system app=ai-kgateway

kubectl apply -f resources/backend.yaml
kubectl apply -f resources/httproute.yaml

### hack 
kubectl create secret generic foo -n kagent --from-literal=Foo=Foo