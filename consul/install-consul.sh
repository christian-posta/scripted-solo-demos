

# Install 0.25.0 version of the chart
helm install -f consul-values.yaml consul-sm hashicorp/consul --version 0.25.0  --namespace consul-system --create-namespace

