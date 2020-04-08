kubectl delete secret -n gloo-system ceposta-password
kubectl -n gloo-system delete --all apidocs.devportal.solo.io               
kubectl -n gloo-system delete --all groups.devportal.solo.io                
kubectl -n gloo-system delete --all portals.devportal.solo.io               
kubectl -n gloo-system delete --all users.devportal.solo.io                 
