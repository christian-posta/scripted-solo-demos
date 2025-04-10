# Set up the vllm models
source ~/bin/ai-keys
kubectl create secret generic hf-token --from-literal=token=$HF_TOKEN 

# deploy the actual models running on vllm
kubectl apply -f llm/gpu-deployment.yaml
kubectl rollout status deployment vllm-llama2-7b
