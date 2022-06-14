
kubectl config delete-cluster kind-kind1
kubectl config delete-context mgmt 
kind delete cluster --name kind1

kubectl config delete-cluster kind-kind2
kubectl config delete-context cluster1
kind delete cluster --name kind2

kubectl config delete-cluster kind-kind3
kubectl config delete-context cluster2
kind delete cluster --name kind3

#rm ~/.kube/config