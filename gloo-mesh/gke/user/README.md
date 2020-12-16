# Create cert
openssl genrsa -out ceposta.key 2048
openssl req -new -key ceposta.key -out ceposta.csr

example: O=meshctl:user,CN=ceposta

Note, O=group and CN=user

# or?
$  step certificate create --template ./step-template.tpl ceposta ceposta.csr ceposta.key --csr --kty RSA --size 2048 --force 

# apply for the CSR
# make sure to put the CSR base64 encoded into the CSR yaml:
cat ceposta.csr | base64
cat ceposta.csr | base64 | pbcopy
kubectl apply -f ceposta-kube-csr.yaml --validate=false

# verify it is there
kubectl get csr

# approve it
kubectl certificate approve ceposta

# Get the actual crt
kubectl get csr/ceposta -o jsonpath="{.status.certificate}" | base64 --decode > ceposta.crt

# create the kubeconfig for john
kind export kubeconfig --name smh-management --kubeconfig ./ceposta-kubeconfig

# Now replace public cert/private key manually...
cat ceposta.key | base64
cat ceposta.key | base64 | pbcopy
cat ceposta.crt | base64 
cat ceposta.crt | base64 | pbcopy

KUBECONFIG=./ceposta-kubeconfig kubectl config set-credentials kind-smh-management --client-key=./ceposta.key --client-certificate=./ceposta.crt


# now try with it
KUBECONFIG=./ceposta-kubeconfig kubectl get po

KUBECONFIG=./user/user-sre/user-sre-kubeconfig kubectl apply -f role-based-api/02-trafficpolicy-fault-injection-sre.yaml 