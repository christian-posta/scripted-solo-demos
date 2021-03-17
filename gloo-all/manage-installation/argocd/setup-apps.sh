DIR=$(dirname ${BASH_SOURCE})

# POD_NAME=$(kubectl get po -n argocd | grep argocd-server | awk '{print $1}')
# login using argocd
# argocd login localhost:8080 --username admin --password $POD_NAME


# argocd app create petclinic --repo http://gogs.gogs.svc.cluster.local/ceposta/petclinic.git --path resources/gloo --dest-server https://kubernetes.default.svc --dest-namespace gloo-system

kubectl apply -f $DIR/petclinic-application.yaml