
NUMBER=${1:-1}

kubectl config delete-cluster kind-kind$NUMBER
kubectl config delete-context cluster$NUMBER
kind delete cluster --name kind$NUMBER

