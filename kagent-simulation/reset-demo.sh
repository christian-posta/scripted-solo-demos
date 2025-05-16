source env.sh

kubectl  delete -f resources/mysql-v1.yaml
kubectl  delete -f resources/neo4j-v1.yaml
kubectl  delete -f resources/backend-v1.yaml
kubectl  delete -f resources/backend-v2.yaml
kubectl  delete -f resources/backend-v3.yaml
kubectl  delete -f resources/frontend-v1.yaml

kubectl  apply -f resources/mysql-v1.yaml
kubectl  apply -f resources/neo4j-v1.yaml
kubectl  apply -f resources/backend-v1.yaml
kubectl  apply -f resources/backend-v2.yaml
kubectl  apply -f resources/backend-v3.yaml
kubectl  apply -f resources/frontend-v1.yaml

kubectl  rollout status deployment