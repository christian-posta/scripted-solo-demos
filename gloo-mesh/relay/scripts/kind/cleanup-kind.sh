kind delete cluster --name kind1
kind delete cluster --name kind2
kind delete cluster --name kind3

kubectl config delete-cluster kind-kind1
kubectl config delete-cluster kind-kind2
kubectl config delete-cluster kind-kind3

kubectl config delete-context gloo-mesh-1
kubectl config delete-context gloo-mesh-2
kubectl config delete-context gloo-mesh-mgmt

sudo sed -i '/web-api/d' /etc/hosts

