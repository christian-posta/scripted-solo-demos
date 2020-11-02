
echo "getting access to the consul server"
kubectl port-forward svc/gloo-consul-server -n consul-system 8500 &
PID=$!

echo "creating certs"
# wait for port-forward
sleep 3s


rm -fr ./certs
mkdir -p ./certs

curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .CertPEM > certs/gateway-proxy.crt

curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .PrivateKeyPEM > certs/gateway-proxy.key

curl -s http://localhost:8500/v1/agent/connect/ca/roots | jq -r .Roots[0].RootCert > certs/rootca.pem


kubectl delete secret -n gloo-system gloo-consul-sm &> /dev/null 
#kubectl create -n gloo-system secret tls gloo-consul-sm --cert=./certs/gateway-proxy.crt --key=./certs/gateway-proxy.key
glooctl create secret tls --name gloo-consul-sm --certchain certs/gateway-proxy.crt --privatekey certs/gateway-proxy.key --rootca certs/rootca.pem

kill -9 $PID


exit 0

# Using the ACL token:
#CONSUL_HTTP_TOKEN=$(kubectl get secret hashicorp-consul-bootstrap-acl-token -o jsonpath={.data.token} | base64 -D)

#curl -s \
#    --header "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" \
#    http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .CertPEM > certs/gateway-proxy.crt
#curl -s \
#    --header "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" \
#    http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .PrivateKeyPEM > certs/gateway-proxy.key
#curl -s \
#    --header "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" \
#    http://localhost:8500/v1/agent/connect/ca/roots | jq -r .Roots[0].RootCert > certs/rootca.pem
