Create a grafana dashboard with the following

export GRAFANA_URL=http://localhost:3000
python dashboard_generator.py --grafana-url $GRAFANA_URL --api-key $GRAFANA_API_KEY




Creating a Grafana API Key:

Log in to your Grafana dashboard as an admin user
Go to Configuration (gear icon) → API Keys
Click "Add API key"
Provide the following information:

Name: A descriptive name like "vLLM Dashboard Generator"
Role: Select "Admin" if you need to create dashboards
Time to live: Choose how long the key should be valid (or leave blank for no expiration)


Click "Add"
Important: Copy the API key immediately as it will only be shown once