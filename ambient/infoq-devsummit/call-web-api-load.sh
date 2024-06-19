
time for i in {1..100}; do kubectl exec -it deploy/sleep -- curl -s -o /dev/null --show-error http://web-api.web-api:8080/ ;  done


