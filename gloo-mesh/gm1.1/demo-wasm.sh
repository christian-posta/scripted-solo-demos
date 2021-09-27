source ./env.sh

# Set up WASM on cluster 1
printf "Setting up wasm on cluster 1....\n\n\n"
kubectl apply --context $CLUSTER_1 -n istioinaction -f ./resources/wasm/bootstrap-ecds-cm.yaml

kubectl patch deployment -n istioinaction recommendation --context ${CLUSTER_1} --patch='{"spec":{"template": {"metadata": {"annotations": {"sidecar.istio.io/bootstrapOverride": "gloo-mesh-custom-envoy-bootstrap"}}}}}'  --type=merge



 Set up WASM on cluster 2
printf "Setting up wasm on cluster 2....\n\n\n"
kubectl apply --context $CLUSTER_2 -n istioinaction -f ./resources/wasm/bootstrap-ecds-cm.yaml

kubectl patch deployment -n istioinaction recommendation --context ${CLUSTER_2} --patch='{"spec":{"template": {"metadata": {"annotations": {"sidecar.istio.io/bootstrapOverride": "gloo-mesh-custom-envoy-bootstrap"}}}}}'  --type=merge

#kubectl apply --context $MGMT_CONTEXT -f ./resources/wasm/wasm-deployment.yaml
