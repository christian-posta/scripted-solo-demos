# Solo.io Enterprise Agentgateway

You must have a running cluster.

You also need an enterprise license key.

```bash
# Install gateway
./setup-gateway.sh

# Install observability
./setup-observability.sh
```

From here, you need to portforward agentgateway

```bash
kubectl port-forward deployments/agentgateway -n enterprise-agentgateway 3000:8080
```

If you need the backend config:

```bash
kubectl port-forward deployments/agentgateway -n enterprise-agentgateway 15000

curl http://localhost:15000/config_dump
```

For metrics, tracing, dashboards:

```bash
kubectl port-forward -n monitoring svc/grafana-prometheus 3002:3000       
```


### Failover dummy service (optional)

The enterprise setup script also applies a small in-cluster service used by the `/failover/openai` demo route:

- **Manifest**: `enterprise/resources/supporting/failover-429.yaml`
- **Service DNS**: `failover-429.enterprise-agentgateway.svc.cluster.local:9959`