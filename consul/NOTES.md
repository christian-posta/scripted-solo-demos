## Updating to latest helm charts


helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install -f consul-values.yaml consul-sm hashicorp/consul --version 0.25.0  --namespace consul-system --create-namespace


Add annotation to any of the Deployments which should get the consul sidecar:

"consul.hashicorp.com/connect-inject": "true"

Add this annotation to make an upstream available on a localhost port:

"consul.hashicorp.com/connect-service-upstreams": "api:9091"


# CA root from consul
curl -s http://localhost:8500/v1/agent/connect/ca/roots | jq -r .Roots[0].RootCert > rootca.pem

# Ge leaf node cert
curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .CertPEM > gateway-proxy.pem

# get leaf node key
curl -s http://localhost:8500/v1/agent/connect/ca/leaf/gloo-service | jq -r .PrivateKeyPEM > gateway-proxy.key







## Old instructions

helm template --name consul ./ | kubectl apply --validate=false -f -

* note you can have N replicas of consul where N >= number of k8s nodes (e.g., minikube should be N=1)
* When turning on boostrapACL, all tokens will be created as k8s secrets

## Delete Consul from k8s

helm template --name consul ./ | kubectl delete -f -

## Bootstrap ACL token

```
BOOTSTRAP_TOKEN=$(kubectl get secret consul-consul-bootstrap-acl-token  -o jsonpath={.data.token} | base64 --decode)
```
