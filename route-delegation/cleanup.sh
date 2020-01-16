kubectl delete virtualservice -n gloo-system banking-vs
kubectl delete routetable -n default --all
kubectl delete authconfig auth0-oidc
kubectl delete secret auth0