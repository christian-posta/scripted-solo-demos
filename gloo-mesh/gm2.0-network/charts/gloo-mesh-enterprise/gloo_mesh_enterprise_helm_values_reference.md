
---
title: "Gloo Mesh Enterprise"
description: Reference for Helm values.
weight: 2
---

|Option|Type|Default Value|Description|
|------|----|-----------|-------------|
|insecure|bool|false|Set to true to enable insecure communication between Gloo Mesh components|
|devMode|bool|false|Set to true to enable dev mode for the logger.|
|verbose|bool|false|If true, enables verbose/debug logging.|
|leaderElection|bool|true|If true, leader election will be enabled|
|adminNamespace|string| |The admin namespace to use for Gloo Mesh. The Admin Namespace will serve as the home for 'global' configruation, such as Workspaces and Kubernetes Clusters. The 'global overrides' WorkspaceSettings will be read from this namespace, if it exists.|
|mgmtClusterName|string|mgmt-cluster|In the special case where the management server is also running in a managed cluster with an agent, set this string to the name of the managed cluster.|
|licenseKey|string| |Gloo Mesh Enterprise license key|
|prometheusUrl|string|http://prometheus-server|Specify the URL of the Prometheus server.|
|prometheus|map[string, interface]|{"alertmanager":{"enabled":false},"enabled":true,"kubeStateMetrics":{"enabled":false},"nodeExporter":{"enabled":false},"podSecurityPolicy":{"enabled":false},"pushgateway":{"enabled":false},"rbac":{"create":true},"server":{"fullnameOverride":"prometheus-server","persistentVolume":{"enabled":false}},"serverFiles":{"prometheus.yml":{"scrape_configs":[{"job_name":"gloo-mesh","kubernetes_sd_configs":[{"role":"endpoints"}],"relabel_configs":[{"action":"keep","regex":true,"source_labels":["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]},{"action":"keep","regex":"gloo-mesh-mgmt-server","source_labels":["__meta_kubernetes_pod_label_app"]},{"action":"keep","regex":"gloo-mesh-mgmt-server","source_labels":["__meta_kubernetes_endpoints_name"]},{"action":"replace","regex":"(.+)","source_labels":["__meta_kubernetes_pod_annotation_prometheus_io_path"],"target_label":"__metrics_path__"},{"action":"replace","regex":"(.+):(?:\\d+);(\\d+)","replacement":"${1}:${2}","source_labels":["__address__","__meta_kubernetes_pod_annotation_prometheus_io_port"],"target_label":"__address__"},{"action":"labelmap","regex":"__meta_kubernetes_service_label_(.+)"},{"action":"replace","source_labels":["__meta_kubernetes_namespace"],"target_label":"namespace"},{"action":"replace","source_labels":["__meta_kubernetes_service_name"],"target_label":"service"}],"scrape_interval":"15s","scrape_timeout":"10s"}]}},"serviceAccounts":{"alertmanager":{"create":false},"nodeExporter":{"create":false},"pushgateway":{"create":false},"server":{"create":true}}}|Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.<MAP_KEY>|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.alertmanager|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.enabled|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.kubeStateMetrics|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.nodeExporter|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.podSecurityPolicy|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.pushgateway|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.rbac|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.server|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.serverFiles|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.serviceAccounts|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|glooMeshMgmtServer|struct|{"relay":{"tlsSecret":{"name":"relay-server-tls-secret"},"signingTlsSecret":{"name":"relay-tls-signing-secret"},"tokenSecret":{"name":"relay-identity-token-secret","namespace":"","key":"token"},"disableCa":false,"disableTokenGeneration":false,"disableCaCertGeneration":false,"pushRbac":true},"maxGrpcMessageSize":"4294967295","concurrency":10}|Configuration for the glooMeshMgmtServer deployment.|
|glooMeshMgmtServer.relay|struct|{"tlsSecret":{"name":"relay-server-tls-secret"},"signingTlsSecret":{"name":"relay-tls-signing-secret"},"tokenSecret":{"name":"relay-identity-token-secret","namespace":"","key":"token"},"disableCa":false,"disableTokenGeneration":false,"disableCaCertGeneration":false,"pushRbac":true}|options for configuring relay on the mgmt server|
|glooMeshMgmtServer.relay.tlsSecret|struct|{"name":"relay-server-tls-secret"}|Reference to a Secret containing TLS Certificates used to secure the Mgmt gRPC Server with TLS.|
|glooMeshMgmtServer.relay.tlsSecret.name|string|relay-server-tls-secret||
|glooMeshMgmtServer.relay.tlsSecret.namespace|string| ||
|glooMeshMgmtServer.relay.signingTlsSecret|struct|{"name":"relay-tls-signing-secret"}|Reference to a Secret containing TLS Certificates used to sign CSRs created by Relay Agents.|
|glooMeshMgmtServer.relay.signingTlsSecret.name|string|relay-tls-signing-secret||
|glooMeshMgmtServer.relay.signingTlsSecret.namespace|string| ||
|glooMeshMgmtServer.relay.tokenSecret|struct|{"name":"relay-identity-token-secret","namespace":"","key":"token"}|Reference to a Secret containing a shared Token for authenticating Relay Agents.|
|glooMeshMgmtServer.relay.tokenSecret.name|string|relay-identity-token-secret|Name of the Kubernetes Secret|
|glooMeshMgmtServer.relay.tokenSecret.namespace|string| |Namespace of the Kubernetes Secret|
|glooMeshMgmtServer.relay.tokenSecret.key|string|token|Key value of the data within the Kubernetes Secret|
|glooMeshMgmtServer.relay.disableCa|bool|false||
|glooMeshMgmtServer.relay.disableTokenGeneration|bool|false||
|glooMeshMgmtServer.relay.disableCaCertGeneration|bool|false||
|glooMeshMgmtServer.relay.pushRbac|bool|true|Instruct relay relay to push RBAC resources to the management server. This is needed if you plan to use multi-cluster RBAC in the dashboard.|
|glooMeshMgmtServer.maxGrpcMessageSize|string|4294967295|Specify to set a custom maximum message size for grpc messages sent and received by the Relay server|
|glooMeshMgmtServer.concurrency|uint16|10|The concurrency to use for translation operations. Default is 10.|
|glooMeshMgmtServer|struct|{"image":{"repository":"gloo-mesh-mgmt-server","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}},"sidecars":{},"floatingUserId":false,"runAsUser":10101,"serviceType":"LoadBalancer","ports":{"grpc":9900,"healthcheck":8090,"stats":9091},"enabled":true}|Configuration for the glooMeshMgmtServer deployment.|
|glooMeshMgmtServer|struct|{"image":{"repository":"gloo-mesh-mgmt-server","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}}||
|glooMeshMgmtServer.image|struct|{"repository":"gloo-mesh-mgmt-server","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshMgmtServer.image.tag|string| |Tag for the container.|
|glooMeshMgmtServer.image.repository|string|gloo-mesh-mgmt-server|Image name (repository).|
|glooMeshMgmtServer.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshMgmtServer.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshMgmtServer.image.pullSecret|string| |Image pull secret.|
|glooMeshMgmtServer.Env[]|slice|[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshMgmtServer.resources|struct|{"requests":{"cpu":"125m","memory":"256Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshMgmtServer.resources.limits|map[string, struct]|null||
|glooMeshMgmtServer.resources.limits.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.resources.limits.<MAP_KEY>|string| ||
|glooMeshMgmtServer.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshMgmtServer.resources.requests.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.resources.requests.<MAP_KEY>|string| ||
|glooMeshMgmtServer.resources.requests.cpu|struct|"125m"||
|glooMeshMgmtServer.resources.requests.cpu|string|DecimalSI||
|glooMeshMgmtServer.resources.requests.memory|struct|"256Mi"||
|glooMeshMgmtServer.resources.requests.memory|string|BinarySI||
|glooMeshMgmtServer.sidecars|map[string, struct]|{}|Configuration for the deployed containers.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshMgmtServer.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshMgmtServer.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshMgmtServer.serviceType|string|LoadBalancer|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshMgmtServer.ports|map[string, uint32]|{"grpc":9900,"healthcheck":8090,"stats":9091}|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.grpc|uint32|9900|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.healthcheck|uint32|8090|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.stats|uint32|9091|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshMgmtServer.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshMgmtServer.enabled|bool|true|Enables or disables creation of the operator deployment/service|
|glooMeshUi|struct|{"settingsName":"settings","auth":{"enabled":false,"backend":"","oidc":{"clientId":"","clientSecret":"","clientSecretName":"","issuerUrl":"","appUrl":"","session":{"backend":"","redis":{"host":""}}}}}|Configuration for the glooMeshUi deployment.|
|glooMeshUi.settingsName|string|settings|Name of the dashboard settings object to use|
|glooMeshUi.auth|struct|{"enabled":false,"backend":"","oidc":{"clientId":"","clientSecret":"","clientSecretName":"","issuerUrl":"","appUrl":"","session":{"backend":"","redis":{"host":""}}}}|Authentication configuration|
|glooMeshUi.auth.enabled|bool|false|Require authentication to access the dashboard|
|glooMeshUi.auth.backend|string| |Authentication backend to use. Supports: oidc|
|glooMeshUi.auth.oidc|struct|{"clientId":"","clientSecret":"","clientSecretName":"","issuerUrl":"","appUrl":"","session":{"backend":"","redis":{"host":""}}}|Settings for the OpenID Connect backend. Only used when backend is set to 'oidc'.|
|glooMeshUi.auth.oidc.clientId|string| |OIDC client ID|
|glooMeshUi.auth.oidc.clientSecret|string| |Plaintext OIDC client secret. Will be base64 encoded and stored in a secret with the name below.|
|glooMeshUi.auth.oidc.clientSecretName|string| |Name of a secret containing the client secret will be stored at|
|glooMeshUi.auth.oidc.issuerUrl|string| |OIDC Issuer |
|glooMeshUi.auth.oidc.appUrl|string| |URL users will use to access the dashboard|
|glooMeshUi.auth.oidc.session|struct|{"backend":"","redis":{"host":""}}|Session storage configuration. If omitted a cookie will be used.|
|glooMeshUi.auth.oidc.session.backend|string| |Session backend to use. Supports: cookie, redis|
|glooMeshUi.auth.oidc.session.redis|struct|{"host":""}|Settings for the Redis backend. Only used when backend is set to 'redis'.|
|glooMeshUi.auth.oidc.session.redis.host|string| |Host a Redis instance is accessible at. Set to 'redis.gloo-mesh.svc.cluster.local:6379' to use the included Redis deployment.|
|glooMeshUi|struct|{"image":{"repository":"gloo-mesh-apiserver","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}},"sidecars":{"console":{"image":{"repository":"gloo-mesh-ui","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":null,"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}},"envoy":{"image":{"repository":"gloo-mesh-envoy","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"ENVOY_UID","value":"0"}],"resources":{"requests":{"cpu":"500m","memory":"256Mi"}}}},"floatingUserId":false,"runAsUser":10101,"serviceType":"ClusterIP","ports":{"console":8090,"grpc":10101,"healthcheck":8081},"enabled":true}|Configuration for the glooMeshUi deployment.|
|glooMeshUi|struct|{"image":{"repository":"gloo-mesh-apiserver","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}}||
|glooMeshUi.image|struct|{"repository":"gloo-mesh-apiserver","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshUi.image.tag|string| |Tag for the container.|
|glooMeshUi.image.repository|string|gloo-mesh-apiserver|Image name (repository).|
|glooMeshUi.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.Env[]|slice|[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key"}}}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.resources|struct|{"requests":{"cpu":"125m","memory":"256Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.resources.limits|map[string, struct]|null||
|glooMeshUi.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshUi.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.resources.requests.cpu|struct|"125m"||
|glooMeshUi.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.resources.requests.memory|struct|"256Mi"||
|glooMeshUi.resources.requests.memory|string|BinarySI||
|glooMeshUi.sidecars|map[string, struct]|{"console":{"image":{"repository":"gloo-mesh-ui","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":null,"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}},"envoy":{"image":{"repository":"gloo-mesh-envoy","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"ENVOY_UID","value":"0"}],"resources":{"requests":{"cpu":"500m","memory":"256Mi"}}}}|Configuration for the deployed containers.|
|glooMeshUi.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshUi.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshUi.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshUi.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshUi.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshUi.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.console|struct|{"image":{"repository":"gloo-mesh-ui","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":null,"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}}|Configuration for the deployed containers.|
|glooMeshUi.sidecars.console.image|struct|{"repository":"gloo-mesh-ui","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshUi.sidecars.console.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.console.image.repository|string|gloo-mesh-ui|Image name (repository).|
|glooMeshUi.sidecars.console.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.sidecars.console.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.sidecars.console.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.console.Env[]|slice|null|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.console.resources|struct|{"requests":{"cpu":"125m","memory":"256Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.console.resources.limits|map[string, struct]|null||
|glooMeshUi.sidecars.console.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.console.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.console.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshUi.sidecars.console.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.console.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.console.resources.requests.cpu|struct|"125m"||
|glooMeshUi.sidecars.console.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.sidecars.console.resources.requests.memory|struct|"256Mi"||
|glooMeshUi.sidecars.console.resources.requests.memory|string|BinarySI||
|glooMeshUi.sidecars.envoy|struct|{"image":{"repository":"gloo-mesh-envoy","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"ENVOY_UID","value":"0"}],"resources":{"requests":{"cpu":"500m","memory":"256Mi"}}}|Configuration for the deployed containers.|
|glooMeshUi.sidecars.envoy.image|struct|{"repository":"gloo-mesh-envoy","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshUi.sidecars.envoy.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.envoy.image.repository|string|gloo-mesh-envoy|Image name (repository).|
|glooMeshUi.sidecars.envoy.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.sidecars.envoy.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.sidecars.envoy.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.envoy.Env[]|slice|[{"name":"ENVOY_UID","value":"0"}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.envoy.resources|struct|{"requests":{"cpu":"500m","memory":"256Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.envoy.resources.limits|map[string, struct]|null||
|glooMeshUi.sidecars.envoy.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.envoy.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.envoy.resources.requests|map[string, struct]|{"cpu":"500m","memory":"256Mi"}||
|glooMeshUi.sidecars.envoy.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.envoy.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.envoy.resources.requests.cpu|struct|"500m"||
|glooMeshUi.sidecars.envoy.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.sidecars.envoy.resources.requests.memory|struct|"256Mi"||
|glooMeshUi.sidecars.envoy.resources.requests.memory|string|BinarySI||
|glooMeshUi.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshUi.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshUi.serviceType|string|ClusterIP|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshUi.ports|map[string, uint32]|{"console":8090,"grpc":10101,"healthcheck":8081}|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.console|uint32|8090|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.grpc|uint32|10101|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.healthcheck|uint32|8081|Specify service ports as a map from port name to port number.|
|glooMeshUi.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshUi.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshUi.enabled|bool|true|Enables or disables creation of the operator deployment/service|
|glooMeshRedis|struct|{"addr":""}|Configuration for the glooMeshRedis deployment.|
|glooMeshRedis.addr|string| |Address to use when connecting to redis|
|glooMeshRedis|struct|{"image":{"repository":"redis","registry":"docker.io","pullPolicy":"IfNotPresent"},"env":[{"name":"MASTER","value":"true"}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}},"sidecars":{},"floatingUserId":false,"runAsUser":10101,"serviceType":"ClusterIP","ports":{"redis":6379},"enabled":true}|Configuration for the glooMeshRedis deployment.|
|glooMeshRedis|struct|{"image":{"repository":"redis","registry":"docker.io","pullPolicy":"IfNotPresent"},"env":[{"name":"MASTER","value":"true"}],"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}}||
|glooMeshRedis.image|struct|{"repository":"redis","registry":"docker.io","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshRedis.image.tag|string| |Tag for the container.|
|glooMeshRedis.image.repository|string|redis|Image name (repository).|
|glooMeshRedis.image.registry|string|docker.io|Image registry.|
|glooMeshRedis.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshRedis.image.pullSecret|string| |Image pull secret.|
|glooMeshRedis.Env[]|slice|[{"name":"MASTER","value":"true"}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshRedis.resources|struct|{"requests":{"cpu":"125m","memory":"256Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshRedis.resources.limits|map[string, struct]|null||
|glooMeshRedis.resources.limits.<MAP_KEY>|struct| ||
|glooMeshRedis.resources.limits.<MAP_KEY>|string| ||
|glooMeshRedis.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshRedis.resources.requests.<MAP_KEY>|struct| ||
|glooMeshRedis.resources.requests.<MAP_KEY>|string| ||
|glooMeshRedis.resources.requests.cpu|struct|"125m"||
|glooMeshRedis.resources.requests.cpu|string|DecimalSI||
|glooMeshRedis.resources.requests.memory|struct|"256Mi"||
|glooMeshRedis.resources.requests.memory|string|BinarySI||
|glooMeshRedis.sidecars|map[string, struct]|{}|Configuration for the deployed containers.|
|glooMeshRedis.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshRedis.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshRedis.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshRedis.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshRedis.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshRedis.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshRedis.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshRedis.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshRedis.serviceType|string|ClusterIP|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshRedis.ports|map[string, uint32]|{"redis":6379}|Specify service ports as a map from port name to port number.|
|glooMeshRedis.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshRedis.ports.redis|uint32|6379|Specify service ports as a map from port name to port number.|
|glooMeshRedis.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshRedis.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshRedis.enabled|bool|true|Enables or disables creation of the operator deployment/service|
