

Notes: 

* Set up the app in Auth0
* You need to put the proxy IP (or set up a DDNS) into the allowed callback urls


CLIENT_ID=<foo bar>
CLIENT_SECRET=<foo bar>

glooctl create secret --namespace gloo-system --name auth0 oauth --client-secret $CLIENT_SECRET

kubectl apply -f gloo-oidc-authh0.yaml

glooctl proxy url