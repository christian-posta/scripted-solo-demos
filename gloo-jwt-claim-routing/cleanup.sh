kubectl delete pod canary-pod primary-pod
kubectl delete svc echoapp

kubectl delete us echoapp -n gloo-system
kubectl delete  vs echoapp -n gloo-system