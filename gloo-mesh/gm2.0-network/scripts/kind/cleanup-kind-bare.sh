
kubectl config delete-cluster kind-kind4
kubectl config delete-context bare-mgmt
kind delete cluster --name kind4


kubectl config delete-cluster kind-kind5
kubectl config delete-context bare-cluster1
kind delete cluster --name kind5


kubectl config delete-cluster kind-kind6
kubectl config delete-context bare-cluster2
kind delete cluster --name kind6

#rm ~/.kube/config