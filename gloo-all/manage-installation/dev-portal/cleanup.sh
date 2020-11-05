DIR=$(dirname ${BASH_SOURCE})
helm uninstall dev-portal -n dev-portal
kubectl delete namespace dev-portal