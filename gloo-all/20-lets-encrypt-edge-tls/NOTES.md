Note, you need to run set up first... but installing cert manager could fail, so need to re-run this line again:

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml