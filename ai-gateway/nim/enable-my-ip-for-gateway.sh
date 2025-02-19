export MY_IP=$(curl -s ipecho.net/plain)
echo "Enabling access for MY_IP: $MY_IP"
kubectl patch svc -n gloo-system gloo-proxy-ai-gateway -p '{"spec": {"loadBalancerSourceRanges": ["'"$MY_IP"/32'"]}}'