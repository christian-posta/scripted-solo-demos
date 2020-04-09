#!/bin/bash

if [ "$#" -gt "0" ]; then
  local_context=$1
fi

if [ "$#" -gt "1" ]; then
  remote_context=$2
fi

if [ "$#" -gt "2" ]; then
  namespace_secrets=$3
fi


#prep for creating kubeconfig of remote cluster
export WORK_DIR=$(pwd)
CLUSTER_NAME=$(kubectl --context $remote_context config view --minify=true -o "jsonpath={.clusters[].name}")
echo "Cluster name: $CLUSTER_NAME"

CONTEXT_NAME=$(kubectl --context $remote_context config view --minify=true -o "jsonpath={.current-context}")
echo "Context name: $CONTEXT_NAME"

export KUBECFG_FILE=/tmp/${CLUSTER_NAME}
SERVER=$(kubectl --context $remote_context config view --minify=true -o "jsonpath={.clusters[].cluster.server}")
NAMESPACE_SYNC=admiral-sync
SERVICE_ACCOUNT=admiral
SECRET_NAME=$(kubectl --context $remote_context get sa ${SERVICE_ACCOUNT} -n ${NAMESPACE_SYNC} -o jsonpath='{.secrets[].name}')
echo "Secret name $SECRET_NAME"
CA_DATA=$(kubectl --context $remote_context get secret ${SECRET_NAME} -n ${NAMESPACE_SYNC} -o "jsonpath={.data['ca\.crt']}")
RAW_TOKEN=$(kubectl --context $remote_context get secret ${SECRET_NAME} -n ${NAMESPACE_SYNC} -o "jsonpath={.data['token']}")
echo 'RAW_TOKEN'
echo $RAW_TOKEN
TOKEN=$(kubectl get --context $remote_context secret ${SECRET_NAME} -n ${NAMESPACE_SYNC} -o "jsonpath={.data['token']}" | base64 --decode)

echo 'TOKEN'
echo $TOKEN


#create kubeconfig for remote cluster
cat <<EOF > ${KUBECFG_FILE}
apiVersion: v1
clusters:
   - cluster:
       certificate-authority-data: ${CA_DATA}
       server: ${SERVER}
     name: ${CLUSTER_NAME}
contexts:
   - context:
       cluster: ${CLUSTER_NAME}
       user: ${CLUSTER_NAME}
     name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
kind: Config
preferences: {}
users:
   - name: ${CLUSTER_NAME}
     user:
       token: ${TOKEN}
EOF

#export variables for initializing the remote cluster creds on control plane cluster
cat <<EOF > remote_cluster_env_vars
export CLUSTER_NAME=${CLUSTER_NAME}
export KUBECFG_FILE=${KUBECFG_FILE}
EOF



source remote_cluster_env_vars

#TBD make sure you have context switched
#create secret on control plane cluster to connect to remote cluster


kubectl --context $local_context delete secret ${CONTEXT_NAME} -n $namespace_secrets
kubectl --context $local_context create secret generic ${CONTEXT_NAME} --from-file ${KUBECFG_FILE} -n $namespace_secrets
kubectl --context $local_context label secret ${CONTEXT_NAME} admiral/sync=true -n $namespace_secrets

rm -rf remote_cluster_env_vars
rm -rf $KUBECFG_FILE