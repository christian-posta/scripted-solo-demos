# install dex
kubectl apply -f resources/dex.yaml -n gloo-system

# Install petlinic
kubectl apply -f resources/petclinic.yaml

# Install default gateway
kubectl apply -f resources/default-vs.yaml


# Create secret

glooctl create secret oauth --client-secret secretvalue oauth


# Create Rego ConfigMap for JWT+OPA

kubectl -n gloo-system create configmap allow-jwt --from-file=resources/check-jwt.rego



. ~/bin/create-aws-secret

echo "killall kubectl"
killall kubectl

. ./port-forward-all.sh
