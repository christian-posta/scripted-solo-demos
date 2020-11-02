## Getting Gloo to work with Consul Service Mesh (mTLS)

If you're using Consul Service Mesh for your east-west service-communication traffic, and you need a powerful ingress/edge gateway Gloo is your best bet. These instructions show how to set up the mTLS route between Gloo and any of the services running in the Consul Service Mesh.

First note: this is intended as a POC to demonstrate capabilities with Gloo OSS. Gloo EE is working on a better UX and intended to be supported under the Gloo EE subscription.

The steps are as follows

1. Configure Gloo to discover services from Consul
1. Get the certificates necessary for Gloo to participate in mTLS
1. Update the discovered Upstream object to use the certificates
1. Use the upstream in a VirtualService

### Configure Gloo to discover services from Consul

Patch your `settings` yaml file with:

```yaml
spec:
  consul:
    address: gloo-consul-server.default:8500
    serviceDiscovery: {}
```

### Get the certificates necessary for Gloo to participate in mTLS

You can query the Consul server directly to get the certs. 

The following example we get the cert and use `glooctl` to create the secret. We do this because Gloo certs can have all three files for mTLS (cert, key, and CA)

```sh
kubectl port-forward svc/gloo-consul-server -n consul-system 8500 &
PID=$!

echo "creating certs"
sleep 3s

curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .CertPEM > certs/gateway-proxy.crt

curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .PrivateKeyPEM > certs/gateway-proxy.key

curl -s http://localhost:8500/v1/agent/connect/ca/roots | jq -r .Roots[0].RootCert > certs/rootca.pem


kubectl delete secret -n gloo-system gloo-consul-sm &> /dev/null 

glooctl create secret tls --name gloo-consul-sm --certchain certs/gateway-proxy.crt --privatekey certs/gateway-proxy.key --rootca certs/rootca.pem

kill -9 $PID
```

### Update the discovered Upstream object to use the certificates

Note when your consul service mesh services get registered, they get two entries: one for the actual service and one for the mTLS enabled version called `<service-name>-sidecar-proxy`. Find your Upstream that has been discovered with the `-sidecar-proxy` name and update it to use the new secret (created in previous step). Example:

```yaml
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  name: web-api-sidecar-proxy
  namespace: gloo-system
spec:
  consul:
    dataCenters:
    - dc1
    serviceName: web-api-sidecar-proxy
  sslConfig:
    secretRef:
      name: gloo-consul-sm
      namespace: gloo-system
```


### Use the upstream in a VirtualService

Example:

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - '*'
    routes:
    - matchers:
      - prefix: /
      routeAction:        
        single:
          upstream:
            name: web-api-sidecar-proxy
            namespace: gloo-system

```
