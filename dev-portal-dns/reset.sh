kubectl delete secret -n gloo-system $(kubectl get secret -n gloo-system -l portals.devportal.solo.io/gloo-system.petstore.petstore-keyscope=true -o jsonpath='{.items[].metadata.name}')
kubectl delete secret -n gloo-system ceposta-password
kubectl -n gloo-system delete --all apidocs.devportal.solo.io               
kubectl -n gloo-system delete --all groups.devportal.solo.io                
kubectl -n gloo-system delete --all portals.devportal.solo.io               
kubectl -n gloo-system delete --all users.devportal.solo.io      

kubectl apply -f resources/petstore-vs.yaml
kubectl delete -f resources/auth-config.yaml
