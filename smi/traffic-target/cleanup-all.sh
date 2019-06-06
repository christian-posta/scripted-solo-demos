. reset-demo.sh

# delete SMI controller

kubectl delete -f resources/consul-smi-controller.yaml

kubectl delete secret consul-smi-acl-token

# delete consul cluster

kubectl delete -f resources/consul.yaml