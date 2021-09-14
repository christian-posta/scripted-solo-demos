source ./env.sh

kubectl --context $MGMT_CONTEXT apply -f resources/access-logging/access-log.yaml