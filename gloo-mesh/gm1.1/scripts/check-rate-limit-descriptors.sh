source ./env.sh

echo "Testing that configuration made it there"
echo "OUTPUT:"
kubectl --context $CLUSTER_1 exec -it deploy/rate-limiter -n gloo-mesh-gateway -- wget -q -O - localhost:9091/rlconfig
