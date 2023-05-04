source ~/bin/gloo-mesh-license-env
source ./env-workshop.sh

### Generate some traffic

echo "generate traffic for cluster 1..."
pod=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- /bin/sh -c 'for i in `seq 1 50`; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9080/productpage; done'



echo "generate traffic for cluster 2..."
pod=$(kubectl --context ${CLUSTER2} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
kubectl --context ${CLUSTER2} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- /bin/sh -c 'for i in `seq 1 50`; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9080/productpage; done'
