Create a grafana dashboard with the following

export GRAFANA_URL=http://localhost:3000
python dashboard_generator.py --grafana-url $GRAFANA_URL --api-key $GRAFANA_API_KEY


To add Envoy Gateway specific dashboards (for now while, we have EG under the covers; this will be removed soon)
https://github.com/envoyproxy/gateway/blob/main/charts/gateway-addons-helm/dashboards/

Creating a Grafana API Key:

Go to the Home Drop Down --> Administration --> Users and access --> Service accounts

Create a user if one doesn;t exist

Then add service account token

Log in to your Grafana dashboard as an admin user
Go to Configuration (gear icon) → API Keys
Click "Add API key"
Provide the following information:

Name: A descriptive name like "vLLM Dashboard Generator"
Role: Select "Admin" if you need to create dashboards
Time to live: Choose how long the key should be valid (or leave blank for no expiration)


Click "Add"
Important: Copy the API key immediately as it will only be shown once


### Reset prom metrics
Enable the admin web-api:
(you have to edit the prom deployment as needed)
- --web.enable-admin-api

curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".*"}'


If you need to re-install prom for some reason:

```bash
helm upgrade my-prometheus prometheus-community/prometheus \
  --reuse-values
```
