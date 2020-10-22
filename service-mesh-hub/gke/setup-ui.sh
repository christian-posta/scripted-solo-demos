#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT

#helm repo add service-mesh-hub-ui https://storage.googleapis.com/service-mesh-hub-enterprise/service-mesh-hub-ui
#helm repo update
#helm install smh-ui service-mesh-hub-ui/service-mesh-hub-ui -n service-mesh-hub --set license_key=${SMH_LICENSE_KEY}

# To uninstall:
# helm uninstall smh-ui -n service-mesh-hub

install-smh-ui

sleep 5s

until [ $(kubectl --context $MGMT_CONTEXT -n service-mesh-hub get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the smh pods to become ready on mgmt cluster"
  sleep 1
done
echo "Port forwarding the UI to port 8090"
kubectl port-forward -n service-mesh-hub svc/service-mesh-hub-console 8090  > /dev/null 2>&1 &