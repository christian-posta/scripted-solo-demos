source ./env-workshop.sh

echo "Testing that configuration made it there"
echo "OUTPUT:"
kubectl --context $CLUSTER1 exec -it deploy/rate-limiter -n gloo-mesh-addons -- wget -q -O - localhost:9091/rlconfig
