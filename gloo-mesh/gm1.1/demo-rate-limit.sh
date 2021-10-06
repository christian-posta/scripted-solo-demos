source ./env.sh

kubectl --context $MGMT_CONTEXT create ns gloo-mesh-gateway 
kubectl --context $MGMT_CONTEXT apply -f resources/gmg-routing/ratelimit-server-config.yaml
kubectl --context $MGMT_CONTEXT apply -f resources/gmg-routing/virtual-gateway-rate-limit-combined.yaml

echo "Sleeping for 5s until rate limit config converges"
sleep 5s

./check-rate-limit-descriptors.sh