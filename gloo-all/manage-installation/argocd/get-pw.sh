DIR=$(dirname ${BASH_SOURCE})

echo "Username/Password for Argo:"
echo "Username: admin"
PW=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
echo "Password: $PW"
