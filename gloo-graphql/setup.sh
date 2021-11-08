VERSION=1.10.0-beta1
source ~/bin/gloo-license-key-env 

bootkind gloo-graphql

helm repo update

helm install gloo glooe/gloo-ee -f /Users/ceposta/scripted-demos/gloo-all/resources/config/default-ee-values.yaml --version $VERSION --namespace gloo-system --create-namespace --set-string license_key=$GLOO_LICENSE


kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/v1.2.9/example/petstore/petstore.yaml

kubectl apply -f ~/dev/istio/latest/samples/sleep/sleep.yaml