supergloo init
#supergloo install istio --namespace default --name istio-istio-system --installation-namespace istio-system   --mtls=false --auto-inject=true

sleep 3

cat <<EOF | kubectl apply --filename -
apiVersion: supergloo.solo.io/v1
kind: Install
metadata:
  name: istio-istio-system
  namespace: default
spec:
  installationNamespace: istio-system
  mesh:
    istio:
      enableAutoInject: true
      enableMtls: false
      version: 1.0.6
EOF

DONE=false
while ! $DONE; do
    echo "Waiting for Istio..."
    sleep 3
    RUNNING=$(kubectl get pod -n istio-system | grep pilot | head -n 1 | awk '{ print $3 }')
    if [ $RUNNING == "Running" ]; then
        DONE=true
    fi
done


kubectl apply -f resources/deploy_loop.yaml

kubectl create ns calc
kubectl label namespace calc istio-injection=enabled
kubectl apply -f resources/deploy_calc.yaml -n calc

# disable istio mtls
kubectl  delete meshpolicy default -n default
code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-java
code $GOPATH/src/github.com/solo-io/squash/contrib/example/service1
# remote path: /home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1
