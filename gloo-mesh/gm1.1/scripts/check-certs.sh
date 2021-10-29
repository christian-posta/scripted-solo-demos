source ../env.sh
for cluster in ${CLUSTER_1} ${CLUSTER_2}; do
  kubectl --context ${cluster} get cm -n istioinaction istio-ca-root-cert -o jsonpath="{.data   ['root-cert\.pem']}" | step certificate inspect -
done
