source env.sh

kubectl --context $CLUSTER_1 exec -it deploy/east-west-gateway -n istio-system -- curl localhost:15000/server_info | grep -i version

kubectl --context $CLUSTER_2 exec -it deploy/east-west-gateway -n istio-system -- curl localhost:15000/server_info | grep -i version
