
DIR="/home/solo/dev/hack/ai-gateway-poc"



kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

helm upgrade -i gloo "$DIR/gloo-ee.tgz" \
  --namespace gloo-system --create-namespace -f "$DIR/values.yaml" \
  --set-string license_key=$GLOO_EE_LICENSE_KEY

kubectl apply -f "$DIR/rbac.yaml"

kubectl rollout restart deployment -n gloo-system gloo

# create tokens here..

source ~/bin/ai-keys

#openai token
kubectl create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

#mistral token
kubectl create secret generic mistralai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $MISTRAL_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

kubectl --namespace=gloo-system create configmap wafrulesets \
  --from-file=waf_ruleset.conf --dry-run=client -oyaml | kubectl apply -f -


cd extproc_py
docker build -f Dockerfile . -t extproc-server
kind load docker-image docker.io/library/extproc-server
kubectl apply -f deploy.yaml
cd ..


cd model_failover
docker build -f Dockerfile . -t model-failover
kind load docker-image docker.io/library/model-failover
kubectl apply -f deploy.yaml
cd ..

kubectl apply -f resources