kubectl create -n kagent configmap agentproxy-config --from-file=config.json=config.json
kubectl create -n kagent configmap openapi-config --from-file=petstore.json=petstore.json
kubectl create -n kagent configmap pubkey-config --from-file=pubkey=pubkey

k delete cm agentproxy-config -n kagent
k delete cm openapi-config -n kagent
k delete cm pubkey-config -n kagent

http://agentproxy.kagent.svc.cluster.local:3000

{"Authorization": "Bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw"}


eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw