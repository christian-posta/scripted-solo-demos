DIR=$(dirname ${BASH_SOURCE})
source env.sh

echo "Using kube context: $CONTEXT"
echo "Setting up Argo Rollouts..."

kubectl create namespace argo-rollouts
kubectl --context $CONTEXT apply -f https://github.com/argoproj/argo-rollouts/releases/download/v1.8.1/install.yaml -n argo-rollouts
kubectl --context $CONTEXT apply -f https://github.com/argoproj/argo-rollouts/releases/download/v1.8.1/dashboard-install.yaml -n argo-rollouts

kubectl --context $CONTEXT rollout status -n argo-rollouts deploy/argo-rollouts

