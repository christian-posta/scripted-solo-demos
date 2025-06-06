# Address of Grafana
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $SCRIPT_DIR/../../env.sh

echo "Using Istio version: $ISTIO_VERSION"

GRAFANA_IP=$(kubectl get svc kube-prometheus-stack-grafana  -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
GRAFANA_HOST="http://$GRAFANA_IP:3000"
echo "Using Grafana at $GRAFANA_HOST"
echo "Waiting for 5s"
sleep 5s


# Login credentials, if authentication is used
GRAFANA_CRED="admin:prom-operator"
# The name of the Prometheus data source to use
GRAFANA_DATASOURCE="Prometheus"
# The version of Istio to deploy
# comes from env.sh
# Import all Istio dashboards
for DASHBOARD in 7639 11829 7636 7630 7645 13277 21306; do
    REVISION="$(curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions -s | jq ".items[] | select(.description | contains(\"${ISTIO_VERSION}\")) | .revision" | tail -n 1)"
    curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions/${REVISION}/download > /tmp/dashboard.json
    echo "Importing $(cat /tmp/dashboard.json | jq -r '.title') (revision ${REVISION}, id ${DASHBOARD})..."
    curl -s -k -u "$GRAFANA_CRED" -XPOST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"dashboard\":$(cat /tmp/dashboard.json),\"overwrite\":true, \
            \"inputs\":[{\"name\":\"DS_PROMETHEUS\",\"type\":\"datasource\", \
            \"pluginId\":\"prometheus\",\"value\":\"$GRAFANA_DATASOURCE\"}]}" \
        $GRAFANA_HOST/api/dashboards/import
    echo -e "\nDone\n"
done
