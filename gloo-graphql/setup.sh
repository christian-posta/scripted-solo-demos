VERSION=1.10.0-beta2
source ~/bin/gloo-license-key-env 

bootkind gloo-graphql

helm repo update

helm install gloo glooe/gloo-ee -f /Users/ceposta/scripted-demos/gloo-all/resources/config/default-ee-values.yaml --version $VERSION --namespace gloo-system --create-namespace --set-string license_key=$GLOO_LICENSE


kind load docker-image --name gloo-graphql gcr.io/solo-test-236622/envoy-gql-fix:v1


# hack to support graphql client until next beta release
kubectl patch deploy/gateway-proxy -n gloo-system -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"gateway-proxy","image":"gcr.io/solo-test-236622/envoy-gql-fix:v1"}]}}}}'

kubectl patch deploy/gloo -n gloo-system -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"gloo","image":"gcr.io/solo-test-236622/gloo-ee:0.0.0-gql"}]}}}}'

kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/v1.2.9/example/petstore/petstore.yaml

kubectl apply -f ~/dev/istio/latest/samples/sleep/sleep.yaml