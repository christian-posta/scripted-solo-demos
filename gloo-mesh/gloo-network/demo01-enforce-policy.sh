. $(dirname ${BASH_SOURCE})/util.sh


source ~/bin/gloo-mesh-license-env
source ./env-workshop.sh

### Generate some traffic
backtotop
desc "Check we can call bookinfo product page "
read -s

pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=not-in-mesh -o jsonpath='{.items[0].metadata.name}')

run "kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w \"%{http_code}\" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0"


desc "Let's configure our workspace (unit of tenancy across clusters) to enable service isolation"
read -s


run "cat ./resources/bookinfo-wss-isolation.yaml"
run "kubectl --context $CLUSTER1 apply -f ./resources/bookinfo-wss-isolation.yaml"


desc "Check what cilium network policies exist"
run "kubectl --context ${CLUSTER1} get ciliumnetworkpolicies  -A"
run "kubectl --context ${CLUSTER1} -n bookinfo-backends get ciliumnetworkpolicies settings-reviews-9080-bookinfo -o yaml"

desc "Try calling revies again"
run "kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w \"%{http_code}\" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0"


desc "Try calling from within the workspace"
pod2=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')

run "kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod2} --image=curlimages/curl -- curl -s -o /dev/null -w \"%{http_code}\" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0"


backtotop
desc "Let's say we want to enable calls across tenants"
read -s


run "cat ./resources/bookinfo-wss-isolation-export.yaml"
run "cat ./resources/httpbin-wss-isolation-import.yaml"
run "kubectl --context $CLUSTER1 apply -f ./resources/bookinfo-wss-isolation-export.yaml"
run "kubectl --context $CLUSTER1 apply -f ./resources/httpbin-wss-isolation-import.yaml"

desc "Now let's call reviews from the httpbin workspace"
run "kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w \"%{http_code}\" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0"

