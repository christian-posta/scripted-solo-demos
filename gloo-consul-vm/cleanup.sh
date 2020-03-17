rm petstore-service.json
docker-compose kill
docker rm -f $(docker ps -a | awk '{ print $1 }')