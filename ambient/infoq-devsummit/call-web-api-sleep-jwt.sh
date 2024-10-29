


TOKEN=$(cat ./resources/istio/jwt/token.jwt)
kubectl exec -it deploy/sleep -- curl -v -H "Authorization: Bearer $TOKEN" http://web-api.web-api:8080/