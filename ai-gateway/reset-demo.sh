
## cleanup task 00
kubectl delete -f resources/00-basic-passthrough/

## cleanup task 01
kubectl delete -f resources/01-call-llm/

## cleanup task 02
kubectl delete -f resources/02-secure-llm-jwt/

## cleanup task 03
kubectl delete -f resources/03-ratelimit-token-usage/



