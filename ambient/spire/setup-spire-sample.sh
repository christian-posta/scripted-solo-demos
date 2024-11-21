
kubectl apply -f ./sample-spire-full/spire-quickstart.yaml

kubectl wait pod --for=condition=ready -n spire -l app=spire-agent

kubectl apply -f ./sample-spire-full/clusterspiffeid.yaml

istioctl install -y -f ./sample-spire-full/istio-spire-config.yaml

# we are hardcoding this into the install spec so it doesn't hang
#kubectl patch deployment istio-ingressgateway -n istio-system -p '{"spec":{"template":{"metadata":{"labels":{"spiffe.io/spire-managed-identity": "true"}}}}}'

kubectl label namespace default istio-injection=enabled --overwrite

kubectl apply -f ./sample-spire-full/sleep-spire.yaml

