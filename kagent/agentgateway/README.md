To deploy the agent gateway:

```bash
kubectl apply -f agentgateway/deployment.yaml
cd agentgateway
./reset-configmaps.sh
```

Then you can go to the UI and deploy a tool server with the following URL

```bash
http://agentgateway.kagent.svc.cluster.local:3000/sse
```

You should also include the following blob of JSON for the auth key:

```json
{"Authorization": "Bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw"}
```

If that doesn't work (the UI), you could deploy the CRD:

```bash
kubectl apply -f agentgateway/toolserver.yaml
```

JWT key

```text
eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw
```