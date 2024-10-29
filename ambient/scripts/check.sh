CONTEXT=${1:-gloo-mesh-mgmt}
NAMESPACE=${2:-gloo-mesh}

until [ $(kubectl --context $CONTEXT -n $NAMESPACE get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the $NAMESPACE pods to become ready"
  sleep 1
done

