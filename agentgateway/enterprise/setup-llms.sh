source .env

## Set up the secrets needed for the LLM routes
kubectl create secret generic openai-secret -n enterprise-agentgateway \
--from-literal="Authorization=Bearer $OPENAI_API_KEY" \
--dry-run=client -oyaml | kubectl apply -f -

kubectl apply -f ./resources/llm/openai.yaml

kubectl create secret generic anthropic-secret -n enterprise-agentgateway \
--from-literal="Authorization=$ANTHROPIC_API_KEY" \
--dry-run=client -oyaml | kubectl apply -f -

kubectl apply -f ./resources/llm/anthropic.yaml

kubectl create secret generic gemini-secret -n enterprise-agentgateway \
--from-literal="Authorization=$GEMINI_API_KEY" \
--dry-run=client -oyaml | kubectl apply -f -

kubectl apply -f ./resources/llm/gemini.yaml


kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: bedrock-secret
  namespace: enterprise-agentgateway
type: Opaque
stringData:
  accessKey: ${AWS_ACCESS_KEY_ID}
  secretKey: ${AWS_SECRET_ACCESS_KEY}
  sessionToken: ${AWS_SESSION_TOKEN}
EOF

kubectl apply -f ./resources/llm/bedrock.yaml