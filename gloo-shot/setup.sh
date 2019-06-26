glooshot register
glooshot init

supergloo install istio \
    --namespace glooshot \
    --name istio-istio-system \
    --installation-namespace istio-system \
    --mtls=true \
    --auto-inject=true



DONE=false
while ! $DONE; do
    echo "Waiting for Istio..."
    sleep 3
    RUNNING=$(kubectl get pod -n istio-system | grep pilot | head -n 1 | awk '{ print $3 }')
    if [ $RUNNING == "Running" ]; then
        DONE=true
    fi
done


supergloo set mesh stats \
    --target-mesh glooshot.istio-istio-system \
    --prometheus-configmap glooshot.glooshot-prometheus-server    


kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl apply -n bookinfo -f resources/bookinfo.yaml    


DONE=false
while ! $DONE; do
    echo "Waiting for bookinfo..."
    sleep 3
    RUNNING=$(kubectl get pod -n bookinfo | grep productpage | head -n 1 | awk '{ print $3 }')
    if [ $RUNNING == "Running" ]; then
        DONE=true
    fi
done
kubectl port-forward -n bookinfo deployment/productpage-v1 9080 & > /dev/null &1>2 &


supergloo apply routingrule trafficshifting \
    --namespace bookinfo \
    --name reviews-vulnerable \
    --dest-upstreams glooshot.bookinfo-reviews-9080 \
    --target-mesh glooshot.istio-istio-system \
    --destination glooshot.bookinfo-reviews-v4-9080:1

    
open http://localhost:9080/productpage?u=normal 