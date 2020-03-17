GLOO_VERSION=1.2.12 docker-compose up -d


PETSTORE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gloo-consul-vm_petstore_1)

cat > petstore-service.json <<EOF
{
  "ID": "petstore1",
  "Name": "petstore",
  "Address": "${PETSTORE_IP}",
  "Port": 8080
}
EOF
