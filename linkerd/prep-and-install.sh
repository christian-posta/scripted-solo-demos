linkerd check --pre
linkerd install | kubectl apply -f -
linkerd check   
kubectl -n linkerd get deploy

# create demo ns
kubectl create ns booksapp
