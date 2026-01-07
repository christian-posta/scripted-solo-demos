# Solo.io Enterprise Agentgateway

You must have a running cluster.

You also need an enterprise license key.

```bash
# Install gateway
./setup-gateway.sh

# Install observability
./setup-observability.sh
```

### Failover dummy service (optional)

The enterprise setup script also applies a small in-cluster service used by the `/failover/openai` demo route:

- **Manifest**: `enterprise/resources/supporting/failover-429.yaml`
- **Service DNS**: `failover-429.enterprise-agentgateway.svc.cluster.local:9959`