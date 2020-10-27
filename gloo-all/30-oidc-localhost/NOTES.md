
# Create the key/cert pair
step certificate create web-api.example.com web-api.key web-api.crt --no-password --profile=self-signed --kty RSA --insecure --subtle

# Create the secret with gloo or k8s:

kubectl create secret tls upstream-tls --key web-api.key --cert web-api.crt --namespace gloo-system

glooctl create secret tls --name upstream-tls --certchain web-api.crt --privatekey web-api.key