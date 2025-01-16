source ../.venv/bin/activate
export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
python load_simulation.py --url="$GLOO_AI_GATEWAY:8080"