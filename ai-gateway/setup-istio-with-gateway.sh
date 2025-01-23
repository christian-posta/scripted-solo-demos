## Calling this script will install istio ambient with
## Gloo Gateway enabled. 
## You should pass in a kubernetes context name as the first argument.
## You can pass in a second argument to add more namespaces to the ambient mode.

CONTEXT="${1:-ai-demo}"

# ./install-gateway-stable.sh $CONTEXT
./install-istio-ambient.sh $CONTEXT "skip"

kubectl --context $CONTEXT label namespace gloo-system istio.io/dataplane-mode=ambient
kubectl --context $CONTEXT label namespace gloo-system ambient.istio.io/bypass-inbound-capture=true

NAMESPACES="${2:-}"

if [[ -n "$NAMESPACES" ]]; then
  echo "Adding the following namespaces for ambient mode: $NAMESPACES"
  for NAMESPACE in $NAMESPACES; do
    kubectl --context $CONTEXT label namespace "$NAMESPACE" istio.io/dataplane-mode=ambient --overwrite
  done
else
  echo "Not going to add any more namespaces."
fi
