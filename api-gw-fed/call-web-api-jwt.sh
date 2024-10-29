source ./jwt.sh 

kubectl exec -it deploy/sleep -- curl -H "Authorization: Bearer $JWT" -v http://web-api.web-api:8080/