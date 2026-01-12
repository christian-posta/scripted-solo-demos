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


## Set up Elicitations

source .env

```bash
./setup-elicitation.sh
```

Perform necessary port forwards to access the UI and backend
```bash
kubectl port-forward service/solo-enterprise-ui -n kagent  4000:80 
kubectl port-forward deployments/agentgateway-enterprise -n enterprise-agentgateway 3000:8080 
```

Get an access token to use for the exchange
```bash
export TOKEN=$(curl -k -X POST "https://demo-keycloak-907026730415.us-east4.run.app/realms/kagent-dev/protocol/openid-connect/token" \
-d "client_id=kagent-ui" \
-d "username=admin" \
-d 'password=$KEYCLOAK_USER_PASSWORD' \
-d "grant_type=password" | jq -r .access_token)
```

Now we can try and access the backend. The first time we do the server will return an error.

Note: this NEEDS to be cleaned up before the official release
```bash
curl localhost:3000/headers -H "Authorization: Bearer $TOKEN"
# There should be a response like the following:
# request needs a token exchange, but token not available in STS, info: TokenExchangeInfo { url: Some("https://example.com/elicitation"), status_url: None }
```

Then you navigate to localhost:4000, login with the same credentials used to get the token above, and then navigate to the elicitations page. Once the oauth flow is completed, try and request again.

```bash
curl localhost:3000/headers -H "Authorization: Bearer $TOKEN"

# There should not be a response like the following
:'
  "headers": {
    "Accept": [
      "*/*"
    ],
    "Authorization": [
      "Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJKV3hWTHRpcFItUTZ3RjJ6bVFLRW94YkZocXdpYksyYUtOTHlScU54ZGo0In0.eyJleHAiOjE3Njc4Njc1MjQsImlhdCI6MTc2NzgyNDMyNCwianRpIjoib25ydHJvOjQ3YmMzMWZmLTM3YTYtYWNkZi1iNjAyLWFhMWY0OGY5NzBmNyIsImlzcyI6Imh0dHBzOi8vZGVtby1rZXljbG9hay05MDcwMjY3MzA0MTUudXMtZWFzdDQucnVuLmFwcC9yZWFsbXMva2FnZW50LWRldiIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiJhY2YwNGYyYi1mNTI5LTQ1ZWYtYTJkOC01MzExZmMzYzgzMDEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJrYWdlbnQtdWkiLCJzaWQiOiI5NWZjNzc1NS0wZTEwLTRkNWQtODIzMS04MDJjZTY1YjJhMGEiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIioiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iLCJkZWZhdWx0LXJvbGVzLWthZ2VudC1kZXYiXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiR3JvdXBzIjpbImFkbWlucyJdLCJuYW1lIjoiYWRtaW4gYWRtaW4iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhZG1pbiIsImdpdmVuX25hbWUiOiJhZG1pbiIsImZhbWlseV9uYW1lIjoiYWRtaW4iLCJlbWFpbCI6ImFkbWluQGthZ2VudC1kZXYub3JnIn0.CVjBsBSrpa2IQi9taL8kj4WMGt55yb8d7Q5nXVo8bLUazQxSbMOtrVY7XbpL9_rZ6UQqhbrqe_05hq2i5I2XxyUDv-TtEKVQ_ZCkNi-B1w7lZ7BIKQeSPQ10pGvJHiIYEkcpbAmSjlQtU6Ct6cNgRk0eA3L_RgkHi2_u2Hr3TqGILcH4cDUFUDCyvZvg6clVv6p0rLq3DO2mMdUbExvkspeuGpVWNJ8y_QvEVavxikGzBnqrj4_9vbKwHixrmZ_-Dnf82N1yvswBfJ1pwUVCjzJDgX5QyJ5GKIZhpekaw3eSvdbnnYdqRbPyJDQfenoKdFP9MjYlzHi59nfbF_i2_w"
    ],
    "Host": [
      "localhost:8080"
    ],
    "User-Agent": [
      "curl/8.14.1"
    ]
  }
}'

```