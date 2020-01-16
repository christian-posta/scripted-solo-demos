glooctl create secret oauth --namespace gloo-system --name auth0 --client-secret $CLIENT_SECRET
kubectl apply -f auth0-oidc.yaml
kubectl apply -f echo-server.yaml