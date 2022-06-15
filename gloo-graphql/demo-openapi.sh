#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


SOURCE_DIR=$PWD


## Set up cluster role bindings

kubectl apply -f - <<EOF
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kube-resource-watcher-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: gloo
  namespace: gloo-system
- kind: ServiceAccount
  name: discovery
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: kube-resource-watcher-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gloo-upstream-mutator-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: discovery
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: gloo-upstream-mutator-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gloo-resource-reader-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: gloo
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: gloo-resource-reader-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: settings-user-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: gloo
  namespace: gloo-system
- kind: ServiceAccount
  name: gateway
  namespace: gloo-system
- kind: ServiceAccount
  name: discovery
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: settings-user-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gloo-resource-mutator-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: gateway
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: gloo-resource-mutator-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gateway-resource-reader-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
- kind: ServiceAccount
  name: gateway
  namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: gateway-resource-reader-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/23-namespace-clusterrolebinding-gateway.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gloo-graphqlschema-mutator-binding-gloo-system
  labels:
    app: gloo
    gloo: rbac
subjects:
  - kind: ServiceAccount
    name: discovery
    namespace: gloo-system
roleRef:
  kind: ClusterRole
  name: gloo-graphqlschema-mutator-gloo-system
  apiGroup: rbac.authorization.k8s.io
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: kube-resource-watcher-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: [""]
  resources: ["pods", "services", "secrets", "endpoints", "configmaps", "namespaces"]
  verbs: ["get", "list", "watch"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: gloo-upstream-mutator-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: ["gloo.solo.io"]
  resources: ["upstreams"]
  # update is needed for status updates
  verbs: ["get", "list", "watch", "create", "update", "delete"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: gloo-resource-reader-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: ["gloo.solo.io", "enterprise.gloo.solo.io"]
  resources: ["upstreams","upstreamgroups", "proxies", "authconfigs"]
  # update is needed for status updates
  verbs: ["get", "list", "watch", "update"]
- apiGroups: ["ratelimit.solo.io"]
  resources: ["ratelimitconfigs","ratelimitconfigs/status"]
  verbs: ["get", "list", "watch", "update"]
- apiGroups: ["graphql.gloo.solo.io"]
  resources: ["graphqlschemas","graphqlschemas/status"]
  verbs: ["get", "list", "watch", "update"]
- apiGroups: [""] # get/update on configmaps for recording envoy metrics
  resources: ["configmaps"]
  verbs: ["get", "update"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: settings-user-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: ["gloo.solo.io"]
  resources: ["settings"]
  # update is needed for status updates
  verbs: ["get", "list", "watch", "create"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: gloo-resource-mutator-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: ["gloo.solo.io"]
  resources: ["proxies"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: gateway-resource-reader-gloo-system
    labels:
        app: gloo
        gloo: rbac
rules:
- apiGroups: ["gateway.solo.io"]
  resources: ["virtualservices", "routetables", "virtualhostoptions", "routeoptions"]
  # update is needed for status updates
  verbs: ["get", "list", "watch", "update"]
- apiGroups: ["gateway.solo.io"]
  resources: ["gateways"]
  # update is needed for status updates, create for creating the default ones.
  verbs: ["get", "list", "watch", "create", "update"]
---
# Source: gloo/templates/20-namespace-clusterrole-gateway.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gloo-graphqlschema-mutator-gloo-system
  labels:
    app: gloo
    gloo: rbac
rules:
  - apiGroups: ["graphql.gloo.solo.io"]
    resources: ["graphqlschemas","graphqlschemas/status"]
    verbs: ["get", "list", "watch", "update", "create"]
EOF


## Update petstore app

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: petstore
  name: petstore
  namespace: default
spec:
  selector:
    matchLabels:
      app: petstore
  replicas: 1
  template:
    metadata:
      labels:
        app: petstore
    spec:
      containers:
      - image: openapitools/openapi-petstore
        name: petstore
        env:
          - name: DISABLE_OAUTH
            value: "1"
          - name: DISABLE_API_KEY
            value: "1"
        ports:
        - containerPort: 8080
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: petstore
  namespace: default
  labels:
    service: petstore
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: petstore
EOF

## endable UDS

kubectl patch settings -n gloo-system default --type=merge --patch '{"spec":{"discovery":{"fdsMode":"BLACKLIST"}}}'

## update images

kubectl -n gloo-system set image deploy/discovery discovery=quay.io/solo-io/test-service:0.0.0-discovery-gql
kubectl -n gloo-system set image deploy/gloo gloo=quay.io/solo-io/test-service:0.0.0-gloo-gql
kubectl -n gloo-system set image deploy/gateway-proxy gateway-proxy=quay.io/solo-io/test-service:0.0.0-gateway-proxy-gql

## create virtual service


kubectl apply -f - <<EOF
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"gateway.solo.io/v1","kind":"VirtualService","metadata":{"annotations":{},"name":"default","namespace":"gloo-system"},"spec":{"virtualHost":{"domains":["*"],"routes":[{"graphqlSchemaRef":{"name":"default-petstore-8080","namespace":"gloo-system"},"matchers":[{"prefix":"/graphql"}]}]}}}
  creationTimestamp: "2021-11-08T21:51:43Z"
  generation: 32
  name: default
  namespace: gloo-system
  resourceVersion: "134832"
  uid: 31dacdfc-ad79-4e8c-8685-48e23cbb7d01
spec:
  virtualHost:
    domains:
    - '*'
    options:
      cors:
        allowCredentials: true
        allowHeaders:
        - apollo-query-plan-experimental
        - content-type
        - x-apollo-tracing
        allowMethods:
        - POST
        allowOriginRegex:
        - \*
    routes:
    - graphqlSchemaRef:
        name: default-petstore-8080
        namespace: gloo-system
      matchers:
      - prefix: /graphql
EOF

