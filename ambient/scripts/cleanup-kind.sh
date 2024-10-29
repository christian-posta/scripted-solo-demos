
kubectl config delete-cluster kind-kind1
kubectl config delete-context ambient 
kind delete cluster --name kind1

#rm ~/.kube/config