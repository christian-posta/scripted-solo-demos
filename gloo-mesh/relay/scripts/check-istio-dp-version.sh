source env.sh

echo "Data plane version on $CLUSTER_1"
kubectl --context $CLUSTER_1 exec -it deploy/east-west-gateway -n istio-system -- curl localhost:15000/server_info | grep -i version

echo ""
echo ""
echo "Data plane version on $CLUSTER_2"
kubectl --context $CLUSTER_2 exec -it deploy/east-west-gateway -n istio-system -- curl localhost:15000/server_info | grep -i version
