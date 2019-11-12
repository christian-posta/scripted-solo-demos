kubectl edit deploy/gateway-proxy-v2 -n gloo-system
need to add:

        - mountPath: /var/run/sds
          name: sds-uds-path
        - mountPath: /var/run/secrets/tokens
          name: istio-token


      - hostPath:
          path: /var/run/sds
          type: ""
        name: sds-uds-path
      - name: istio-token
        projected:
          defaultMode: 420
          sources:
          - serviceAccountToken:
              audience: istio-ca
              expirationSeconds: 43200
              path: istio-token


kubectl edit upstream default-productpage-9080  -n gloo-system
kubectl edit upstream hello-v2-helloworld-5000  -n gloo-system
  
need to add:

    sslConfig:
      sds:
        callCredentials:
          fileCredentialSource:
            header: istio_sds_credential_header-bin
            tokenFileName: /var/run/secrets/kubernetes.io/serviceaccount/token
        certificatesSecretName: default
        targetUri: unix:/var/run/sds/uds_path
        validationContextName: ROOTCA

Istio 1.3:
    sslConfig:
      sds:
        callCredentials:
          fileCredentialSource:
            header: istio_sds_credential_header-bin
            tokenFileName: /var/run/secrets/tokens/istio-token
        certificatesSecretName: default
        targetUri: unix:/var/run/sds/uds_path
        validationContextName: ROOTCA


add route:
glooctl add route --name prodpage --namespace gloo-system --path-prefix / --dest-name default-productpage-9080 --dest-namespace gloo-system

glooctl add route --name hello-v2 --namespace gloo-system --path-prefix / --prefix-rewrite /hello --dest-name hello-v2-helloworld-5000 --dest-namespace gloo-system

get url:
glooctl proxy url



showing the values:
kubectl get -o yaml upstream default-productpage-9080  -n gloo-system
kubectl get -o deploy/gateway-proxy-v2 -n gloo-system




# do first:
install CRDS!!!!

helm template install/kubernetes/helm/istio \
    --name istio \
    --namespace istio-system \
    --set certmanager.enabled=true \
    --set certmanager.email=christian@solo.io \
    --set gateways.istio-ingressgateway.sds.enabled=true \
    --set kiali.enabled=true \
    --set grafana.enabled=true | kubectl apply -f -    

# then layer this on top:
helm template install/kubernetes/helm/istio \
    --name istio \
    --namespace istio-system \
    --set certmanager.enabled=true \
    --set certmanager.email=christian@solo.io \
    --set global.sds.enabled=true \
    --set gateways.istio-ingressgateway.sds.enabled=true \
    --set kiali.enabled=true \
    --set global.k8sIngress.enabled=true \
    --set grafana.enabled=true | kubectl apply -f -




# delete and clean up
helm template install/kubernetes/helm/istio \
    --name istio \
    --namespace istio-system \
    --set certmanager.enabled=true \
    --set certmanager.email=christian@solo.io \
    --set global.sds.enabled=true \
    --set gateways.istio-ingressgateway.sds.enabled=true \
    --set kiali.enabled=true \
    --set global.k8sIngress.enabled=true \
    --set grafana.enabled=true | kubectl delete -f -


    

curl -v -H "Host: hello-v1.34.68.176.198.xip.io" https://34.68.176.198:443/


curl -v hello-v1.34.68.176.198.xip.io


curl -v -k   https://hello-v1.35.239.201.203.xip.io:443/ --resolve hello-v1.35.239.201.203.xip.io:443:34.68.176.198



Service authZ


Enable RBAC:

apiVersion: "rbac.istio.io/v1alpha1"
kind: ClusterRbacConfig
metadata:
  name: default
spec:
  mode: 'ON_WITH_INCLUSION'
  inclusion:
    namespaces: ["foo"]

apiVersion: rbac.istio.io/v1alpha1
kind: ServiceRole
metadata:
  name: ns-gloo-system
  namespace: foo
spec:
  rules:
  - services: ["httpbin.foo.svc.cluster.local"]
    methods: ["GET"]
---
apiVersion: rbac.istio.io/v1alpha1
kind: ServiceRoleBinding
metadata:
  name: ns-gloo-system
  namespace: foo
spec:
  roleRef:
    kind: ServiceRole
    name: ns-gloo-system
  subjects:
  - properties:
      source.namespace: "gloo-system"    