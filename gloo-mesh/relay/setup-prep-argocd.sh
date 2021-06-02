DIR=$(dirname ${BASH_SOURCE})
source env.sh

# http://argo.mesh.ceposta.solo.io

kubectl --context $MGMT_CONTEXT apply -f resources/gitops/argocd/gloo-mesh-application.yaml