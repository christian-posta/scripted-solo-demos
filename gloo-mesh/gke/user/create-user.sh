USER=${1:-user-ceposta}
echo "Creating user $USER"

kubectl apply -f ./clusterrolebinding.yaml


rm -fr ./$USER > /dev/null 2>&1
mkdir -p ./$USER > /dev/null 2>&1

# delete an existing csr if it exists
kubectl delete csr $USER > /dev/null 2>&1

echo "Generating key and CSR"
pushd ./$USER
step certificate create --template ../step-template.tpl $USER $USER.csr $USER.key --csr --kty RSA --size 2048 --force --insecure --no-password

CSR=$(cat $USER.csr | base64)

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  groups:
  - system:authenticated
  - meshctl:user
  request: $CSR
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

echo "Approving the CSR"
sleep 2s

kubectl certificate approve $USER

sleep 2s

kubectl get csr/$USER -o jsonpath="{.status.certificate}" | base64 --decode > $USER.crt

kind export kubeconfig --name smh-management --kubeconfig ./$USER-kubeconfig

KUBECONFIG=./$USER-kubeconfig kubectl config set-credentials kind-smh-management --client-key=./$USER.key --client-certificate=./$USER.crt --embed-certs
popd

echo "Try with:"
echo "KUBECONFIG=./$USER/$USER-kubeconfig kubectl get trafficpolicy"