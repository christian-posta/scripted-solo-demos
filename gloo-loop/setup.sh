
kubectl apply -f resources/gloo.yaml
kubectl apply -f resources/loop.yaml

kubectl create ns calc
kubectl apply -f resources/calc.yaml -n calc
./patch-service2-ise.sh

#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-java
#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service1
# remote path: /home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1

kubectl apply -f resources/default-vs.yaml