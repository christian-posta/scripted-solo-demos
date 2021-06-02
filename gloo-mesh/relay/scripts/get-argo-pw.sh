DIR=$(dirname ${BASH_SOURCE})
source ../../env.sh
echo "Username/Password for Argo:"
echo "Username: admin"
PW=$(kubectl --context $MGMT_CONTEXT get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
echo "Password: $PW"
