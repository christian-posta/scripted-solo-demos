
DIR="/home/solo/dev/hack/ai-gateway-poc"

./build-extproc.sh

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


source ~/bin/gloo-mesh-license-env
helm upgrade -i gloo "$DIR/custom_api/gloo-ee.tgz" \
  --namespace gloo-system --create-namespace -f "$DIR/custom_api/values.yaml" \
  --set-string license_key=$GLOO_MESH_LICENSE


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

kubectl apply -f resources/gateway/gateway.yaml