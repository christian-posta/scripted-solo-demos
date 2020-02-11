echo "This depends on Gloo installed already"
echo "Tested with Gloo 1.3.3"

#install consul
kubectl apply -f resources/consul-1.6.2.yaml

# to be able to get to the consul server
kubectl apply -f resources/default-vs.yaml

sleep 5s

consul members -http-addr $(glooctl proxy url)