This demo is expected to run on a cluster with at least 3 nodes



## Bootstrap ACL token

```
BOOTSTRAP_TOKEN=$(kubectl get secret consul-consul-bootstrap-acl-token  -o jsonpath={.data.token} | base64 --decode)
```


## Creating SMI token:

First create the Token for SMI:

```
consul acl token create -description "read/write access for the consul-smi-controller" -policy-name global-management -token=$BOOTSTRAP_TOKEN
```

Then take the output of "Secret ID" and use that as $TOKEN

```
kubectl create secret generic consul-smi-acl-token --from-literal=token=$TOKEN
```