Steps to demo:

Note, we need to forward hubble UI:

> cilium hubble ui

Useful to know whether Cilium recognizes the GatewayAPI

> kubectl get gatewayclasses.gateway.networking.k8s.io 


## Deploying basic Gateway to expose helloworld-v1

> kubectl apply -f resources/gateway/basic-http.yaml 

> kubectl get gateway my-gateway

> kubectl get gateway my-gateway

> kubectl delete -f resources/gateway/basic-http.yaml

## TLS Gateway API:

Create cert (note, this cert is only valid for approx a day):

> mkdir certs
> step certificate create demo.helloworld.com ./certs/leaf.crt ./certs/leaf.key --profile self-signed --subtle --no-password --insecure


> kubectl create secret tls helloworld-gw-cert --key=./certs/leaf.key --cert=./certs/leaf.crt

> kubectl apply -f resources/gateway/tls-http.yaml


NOTE: how to call TLS endpoint:

> GW_IP=$(kubectl get gateway my-tls-gateway | grep gateway | awk '{ print $3 }')
> curl -H "Host: demo.helloworld.com" https://demo.helloworld.com:443/hello --cacert ./certs/leaf.crt --resolve demo.helloworld.com:443:$GW_IP


> kubectl delete -f resources/gateway/tls-http.yaml

> rm -fr ./certs


## Traffic Splitting

> kubectl apply -f resources/gateway/traffic-split-http.yaml 

> GW_IP=$(kubectl get gateway my-splitting-gateway | grep gateway | awk '{ print $3 }')

> curl http://$GW_IP/hello




Controlling the "Envoy" injection:
https://docs.cilium.io/en/stable/security/network/proxy/envoy/

Helm values (specifically check the envoy.* helm values)
https://docs.cilium.io/en/stable/helm-reference/#helm-reference

