
kubectl config delete-cluster kind-$1
kubectl config delete-context $1
kind delete cluster --name $1


#rm ~/.kube/config
