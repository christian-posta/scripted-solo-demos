source env.sh

kubectl --context ${CLUSTER} delete -f resources/mysql-v1.yaml
kubectl --context ${CLUSTER} delete -f resources/neo4j-v1.yaml
kubectl --context ${CLUSTER} delete -f resources/backend-v1.yaml
kubectl --context ${CLUSTER} delete -f resources/backend-v2.yaml
kubectl --context ${CLUSTER} delete -f resources/backend-v3.yaml
kubectl --context ${CLUSTER} delete -f resources/frontend-v1.yaml

kubectl --context ${CLUSTER} apply -f resources/mysql-v1.yaml
kubectl --context ${CLUSTER} apply -f resources/neo4j-v1.yaml
kubectl --context ${CLUSTER} apply -f resources/backend-v1.yaml
kubectl --context ${CLUSTER} apply -f resources/backend-v2.yaml
kubectl --context ${CLUSTER} apply -f resources/backend-v3.yaml
kubectl --context ${CLUSTER} apply -f resources/frontend-v1.yaml

kubectl --context ${CLUSTER} rollout status deployment