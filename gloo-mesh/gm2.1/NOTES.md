Things we need to sort:

* need to be able to have target port for virtualdestination while exposing default ports
https://github.com/solo-io/gloo-mesh-enterprise/issues/2751

* should be able to have east-west gateway outside of workspace?
https://github.com/solo-io/gloo-mesh-enterprise/issues/2915




pod=$(kubectl --context gm-cluster1 -n bookinfo-backends get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
kubectl --context gm-cluster1 -n bookinfo-backends debug -i -q ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0


kubectl apply --context ${CLUSTER1} -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: WorkspaceSettings
metadata:
  name: bookinfo
  namespace: bookinfo-frontends
spec:
  importFrom:
  - workspaces:
    - name: gateways
    resources:
    - kind: SERVICE
  exportTo:
  - workspaces:
    - name: gateways
    resources:
    - kind: SERVICE
      labels:
        app: productpage
    - kind: SERVICE
      labels:
        app: reviews
    - kind: ALL
      labels:
        expose: "true"
  options:
    serviceIsolation:
      enabled: true
      trimProxyConfig: true
EOF



********************************************************************************************************
Basic Commands To Review The Env
********************************************************************************************************
kubectl --context gm-cluster1

kubectl --context gm-cluster1 get AuthorizationPolicy -A 
kubectl --context gm-cluster1 get AccessPolicy -A 
kubectl --context gm-cluster1 get NetworkPolicy -A 
kubectl --context gm-cluster1 get CiliumNetworkPolicy -A 
kubectl --context gm-cluster1 get peerauthentication -A 


********************************************************************************************************
Istio Demos
********************************************************************************************************


Identity:

openssl s_client -connect reviews.bookinfo-backends:9080 -showcerts


AuthPolicy:
product_pod=$(kubectl --context gm-cluster1 -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
kubectl --context gm-cluster1 -n bookinfo-frontends debug -i -q ${product_pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews.bookinfo-backends:9080/reviews/0

details_pod=$(kubectl --context gm-cluster1 -n bookinfo-backends get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
kubectl --context gm-cluster1 -n bookinfo-backends debug -i -q ${details_pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0



product_pod=$(kubectl --context cluster1 -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
kubectl --context cluster1 -n bookinfo-frontends debug -i -q ${product_pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews.bookinfo-backends:9080/reviews/0


details_pod=$(kubectl --context cluster1 -n bookinfo-backends get pods -l app=details -o jsonpath='{.items[0].metadata.name}')
kubectl --context cluster1 -n bookinfo-backends debug -i -q ${details_pod} --image=curlimages/curl --image-pull-policy=Always -- curl --max-time 5 http://reviews:9080/reviews/0

Apply:

cat resources/webinar/reviews-auth-policy.yaml
kubectl --context gm-cluster1 apply -f resources/webinar/reviews-auth-policy.yaml

Cleanup:

kubectl --context gm-cluster1 delete -f resources/webinar/reviews-auth-policy.yaml



********************************************************************************************************
Network Demo
********************************************************************************************************

*** OPTIONAL ***
cat resources/webinar/reviews-ciliumnetworkpolicy.yaml
kubectl --context gm-cluster1 apply -f resources/webinar/reviews-ciliumnetworkpolicy.yaml
kubectl --context gm-cluster1 delete -f resources/webinar/reviews-ciliumnetworkpolicy.yaml



*** DO THIS ONE ***
kubectl --context gm-cluster1 get discoveredcnis -A


cat resources/webinar/reviews-accesspolicy.yaml
kubectl --context gm-cluster1 apply -f resources/webinar/reviews-accesspolicy.yaml
kubectl --context gm-cluster1 delete -f resources/webinar/reviews-accesspolicy.yaml

kubectl --context gm-cluster1 get AuthorizationPolicy -A 
kubectl --context gm-cluster1 get CiliumNetworkPolicy -A 
kubectl --context gm-cluster1 get peerauthentication -A 




cat resources/webinar/workspacesettings.yaml
kubectl --context gm-cluster1 apply -f resources/webinar/workspacesettings.yaml
kubectl --context gm-cluster1 delete -f resources/webinar/workspacesettings.yaml


********************************************************************************************************
Backuo
********************************************************************************************************

kubectl --context gm-cluster1 apply -f resources/webinar/default-peer-authentication.yaml
kubectl --context gm-cluster1 delete -f resources/webinar/default-peer-authentication.yaml