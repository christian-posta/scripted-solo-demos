

NS="${KUBEFED_NAMESPACE:-kube-federation-system}"

INSPECT_PATH='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

CLUSTERS="$(kubectl get kubefedclusters -n "${NS}" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}')"
for cluster in ${CLUSTERS};
do
  if [[ "${LOCAL_TESTING}" ]]; then
    ENDPOINT="$(kubectl config view -o jsonpath='{.clusters[?(@.name == "'"${cluster}"'")].cluster.server}')"
  else
    IP_ADDR="$(docker inspect -f "${INSPECT_PATH}" "${cluster}-control-plane")"
    ENDPOINT="https://${IP_ADDR}:6443"
  fi
  kubectl patch kubefedclusters -n "${NS}" "${cluster}" --type merge \
          --patch "{\"spec\":{\"apiEndpoint\":\"${ENDPOINT}\"}}"
done
