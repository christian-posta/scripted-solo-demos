

source env.sh

docker pull mysql:9.2.0 || true 
kind load docker-image mysql:9.2.0 --name ${CLUSTER_NAME} || true

docker pull bitnami/neo4j:5.26.1 || true
kind load docker-image bitnami/neo4j:5.26.1 --name ${CLUSTER_NAME} || true

docker pull nicholasjackson/fake-service:v0.26.2 || true
kind load docker-image nicholasjackson/fake-service:v0.26.2 --name ${CLUSTER_NAME} || true

docker pull node:23-alpine || true
kind load docker-image node:23-alpine --name ${CLUSTER_NAME} || true

./reset-demo.sh
