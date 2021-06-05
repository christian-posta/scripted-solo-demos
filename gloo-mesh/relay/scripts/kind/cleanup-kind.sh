kind delete cluster --name kind1
kind delete cluster --name kind2
kind delete cluster --name kind3

sudo sed -i '/web-api/d' /etc/hosts