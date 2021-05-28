If keys get mangled somehow, just run this on your local machine:

generate-ca
generate-cert-for edge-west
generate-cert-for edge-east
generate-cert-for edge-europe

Then run the following to create the certs:

glooctl create secret tls --name edge-west-failover --certchain ./gloo/certs/edge-west.crt --privatekey ./gloo/certs/keys/edge-west.key --rootca ./gloo/certs/root-ca.crt 

glooctl create secret tls --name edge-east-failover --certchain ./gloo/certs/edge-east.crt --privatekey ./gloo/certs/keys/edge-east.key --rootca ./gloo/certs/root-ca.crt 

glooctl create secret tls --name edge-europe-failover --certchain ./gloo/certs/edge-europe.crt --privatekey ./gloo/certs/keys/edge-europe.key --rootca ./gloo/certs/root-ca.crt 