## Updating to latest helm charts

## Installing into kubernetes from helm chart:

helm template --name consul ./ | kubectl apply --validate=false -f -

* note you can have N replicas of consul where N >= number of k8s nodes (e.g., minikube should be N=1)
* When turning on boostrapACL, all tokens will be created as k8s secrets

## Delete Consul from k8s

helm template --name consul ./ | kubectl delete -f -

## Bootstrap ACL token

```
BOOTSTRAP_TOKEN=$(kubectl get secret consul-consul-bootstrap-acl-token  -o jsonpath={.data.token} | base64 --decode)
```
