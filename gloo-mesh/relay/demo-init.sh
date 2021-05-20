source env.sh
kubectl --context $MGMT_CONTEXT apply -f resources/virtual-mesh.yaml

. ./scripts/check-virtualmesh.sh