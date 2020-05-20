source env.sh

echo "Creating clusters"
. $KUBEFED_BASE/scripts/create-clusters.sh

# Install Helm, repo, charts
echo "Installing Helm"
cat << EOF | kubectl --context $CLUSTER_1 apply -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF


helm2 repo add kubefed-charts https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/charts

helm2 install kubefed-charts/kubefed --name kubefed --version=0.3.0 --namespace kube-federation-system --devel