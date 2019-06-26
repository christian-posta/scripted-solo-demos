kubectl delete -f resources/experiment.yaml
kubectl delete -f resources/experiment-repeat.yaml
kubectl delete pod -l app=prometheus -n glooshot
kubectl delete routingrule -n bookinfo reviews-resilient
supergloo apply routingrule trafficshifting \
    --namespace bookinfo \
    --name reviews-vulnerable \
    --dest-upstreams glooshot.bookinfo-reviews-9080 \
    --target-mesh glooshot.istio-istio-system \
    --destination glooshot.bookinfo-reviews-v4-9080:1