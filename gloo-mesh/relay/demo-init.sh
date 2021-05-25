source env.sh
kubectl --context $MGMT_CONTEXT apply -f resources/virtual-mesh.yaml

. ./scripts/check-virtualmesh.sh

## Create demo namespace for config
## All config for the demos will go into this namespace
kubectl --context $MGMT_CONTEXT create ns demo-config