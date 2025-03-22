source env.sh

echo "Using kube context: $CONTEXT"
echo "Using Istio version: $ISTIO_VERSION"


NAMESPACES="${1:-default}"

if [[ -n "$NAMESPACES" ]]; then
  echo "Adding the following namespaces for ambient mode: $NAMESPACES"
  for NAMESPACE in $NAMESPACES; do
    echo "Going to label namespace: $NAMESPACE"
    if ! kubectl --context $CONTEXT label namespace $NAMESPACE "istio.io/dataplane-mode=ambient" --overwrite; then
      echo "Failed to label namespace: $NAMESPACE. It may not exist or is already labeled."
    fi
  done
else
  echo "Not going to add any more namespaces."
fi

