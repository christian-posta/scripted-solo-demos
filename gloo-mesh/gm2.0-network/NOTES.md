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

k get AuthorizationPolicy -A --context gm-cluster1
k get NetworkPolicy -A --context gm-cluster1
k get peerauthentication -A --context gm-cluster1


apiVersion: security.policy.gloo.solo.io/v2
kind: AccessPolicy
metadata:
  name: reviews-access
  namespace: bookinfo-backends
spec:
  applyToDestinations:
  - port:
      number: 9080
    selector:
      labels:
        app: reviews
  config:
    authn:
      tlsMode: STRICT
    authz:
      allowedClients:
      - serviceAccountSelector:
          labels:
            app: productpage
      allowedPaths:
      - /reviews*


kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/reviews-accesspolicy.yaml

