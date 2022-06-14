
---
title: "Gloo Mesh Agent"
description: Reference for Helm values.
weight: 2
---

|Option|Type|Default Value|Description|
|------|----|-----------|-------------|
|insecure|bool|false|Set to true to enable insecure communication between Gloo Mesh components|
|devMode|bool|false|Set to true to enable dev mode for the logger.|
|verbose|bool|false|If true, enables verbose/debug logging.|
|leaderElection|bool|true|If true, leader election will be enabled|
|cluster|string| |the cluster in which the agent will deployed|
|relay|struct|{"serverAddress":"","authority":"gloo-mesh-mgmt-server.gloo-mesh","clientTlsSecret":{"name":"relay-client-tls-secret"},"rootTlsSecret":{"name":"relay-root-tls-secret"},"tokenSecret":{"name":"relay-identity-token-secret","namespace":"","key":"token"}}|options for configuring relay on the agent|
|relay.serverAddress|string| |address of the relay server|
|relay.authority|string|gloo-mesh-mgmt-server.gloo-mesh|set the authority/host header to this value when dialing the Relay gRPC Server|
|relay.clientTlsSecret|struct|{"name":"relay-client-tls-secret"}|Reference to a Secret containing the Client TLS Certificates used to identify the Relay Agent to the Server. If the secret does not exist, a Token and Root cert secret are required.|
|relay.clientTlsSecret.name|string|relay-client-tls-secret||
|relay.clientTlsSecret.namespace|string| ||
|relay.rootTlsSecret|struct|{"name":"relay-root-tls-secret"}|Reference to a Secret containing a Root TLS Certificates used to verify the Relay Server Certificate. The secret can also optionally specify a 'tls.key' which will be used to generate the Agent Client Certificate.|
|relay.rootTlsSecret.name|string|relay-root-tls-secret||
|relay.rootTlsSecret.namespace|string| ||
|relay.tokenSecret|struct|{"name":"relay-identity-token-secret","namespace":"","key":"token"}|Reference to a Secret containing a shared Token for authenticating to the Relay Server|
|relay.tokenSecret.name|string|relay-identity-token-secret|Name of the Kubernetes Secret|
|relay.tokenSecret.namespace|string| |Namespace of the Kubernetes Secret|
|relay.tokenSecret.key|string|token|Key value of the data within the Kubernetes Secret|
|maxGrpcMessageSize|string|4294967295|Specify to set a custom maximum message size for grpc messages sent and received by the Relay server|
|metricsBufferSize|int|50|the number of metrics messages to buffer per envoy proxy|
|accessLogsBufferSize|int|50|the number of access logs to buffer per envoy proxy|
|istiodSidecar|struct|{"createRoleBinding":false,"istiodServiceAccount":{"name":"istiod","namespace":"istio-system"}}|settings pertaining to the istiod sidecar deployment|
|istiodSidecar.createRoleBinding|bool|false|create cluster role binding needed by istiod sidecar|
|istiodSidecar.istiodServiceAccount|struct|{"name":"istiod","namespace":"istio-system"}|object reference to istiod service account|
|istiodSidecar.istiodServiceAccount.name|string|istiod||
|istiodSidecar.istiodServiceAccount.namespace|string|istio-system||
|ext-auth-service|struct|{"enabled":false,"extraTemplateAnnotations":{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}}|customizations to the ext-auth-service helm chart|
|ext-auth-service.enabled|bool|false|if true, deploy the dependency service (default false)|
|ext-auth-service.extraTemplateAnnotations|map[string, string]|{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}|extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|ext-auth-service.extraTemplateAnnotations.<MAP_KEY>|string| |extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|ext-auth-service.extraTemplateAnnotations.proxy.istio.io/config|string|{ "holdApplicationUntilProxyStarts": true }|extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|rate-limiter|struct|{"enabled":false,"extraTemplateAnnotations":{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}}|customizations to the rate-limiter helm chart|
|rate-limiter.enabled|bool|false|if true, deploy the dependency service (default false)|
|rate-limiter.extraTemplateAnnotations|map[string, string]|{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}|extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|rate-limiter.extraTemplateAnnotations.<MAP_KEY>|string| |extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|rate-limiter.extraTemplateAnnotations.proxy.istio.io/config|string|{ "holdApplicationUntilProxyStarts": true }|extra annotations to add to the dependency service pods. Defaults to proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'|
|glooMeshAgent|struct|{"image":{"repository":"gloo-mesh-agent","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}}],"resources":{"requests":{"cpu":"50m","memory":"128Mi"}},"sidecars":{},"floatingUserId":false,"runAsUser":10101,"serviceType":"ClusterIP","ports":{"grpc":9977,"http":9988,"stats":9091},"enabled":true}|Configuration for the glooMeshAgent deployment.|
|glooMeshAgent|struct|{"image":{"repository":"gloo-mesh-agent","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}}],"resources":{"requests":{"cpu":"50m","memory":"128Mi"}}}||
|glooMeshAgent.image|struct|{"repository":"gloo-mesh-agent","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"}|Specify the container image|
|glooMeshAgent.image.tag|string| |Tag for the container.|
|glooMeshAgent.image.repository|string|gloo-mesh-agent|Image name (repository).|
|glooMeshAgent.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshAgent.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshAgent.image.pullSecret|string| |Image pull secret.|
|glooMeshAgent.Env[]|slice|[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshAgent.resources|struct|{"requests":{"cpu":"50m","memory":"128Mi"}}|Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshAgent.resources.limits|map[string, struct]|null||
|glooMeshAgent.resources.limits.<MAP_KEY>|struct| ||
|glooMeshAgent.resources.limits.<MAP_KEY>|string| ||
|glooMeshAgent.resources.requests|map[string, struct]|{"cpu":"50m","memory":"128Mi"}||
|glooMeshAgent.resources.requests.<MAP_KEY>|struct| ||
|glooMeshAgent.resources.requests.<MAP_KEY>|string| ||
|glooMeshAgent.resources.requests.cpu|struct|"50m"||
|glooMeshAgent.resources.requests.cpu|string|DecimalSI||
|glooMeshAgent.resources.requests.memory|struct|"128Mi"||
|glooMeshAgent.resources.requests.memory|string|BinarySI||
|glooMeshAgent.sidecars|map[string, struct]|{}|Configuration for the deployed containers.|
|glooMeshAgent.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshAgent.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshAgent.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshAgent.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshAgent.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshAgent.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshAgent.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshAgent.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshAgent.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshAgent.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshAgent.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshAgent.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshAgent.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshAgent.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshAgent.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshAgent.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshAgent.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshAgent.serviceType|string|ClusterIP|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshAgent.ports|map[string, uint32]|{"grpc":9977,"http":9988,"stats":9091}|Specify service ports as a map from port name to port number.|
|glooMeshAgent.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshAgent.ports.grpc|uint32|9977|Specify service ports as a map from port name to port number.|
|glooMeshAgent.ports.http|uint32|9988|Specify service ports as a map from port name to port number.|
|glooMeshAgent.ports.stats|uint32|9091|Specify service ports as a map from port name to port number.|
|glooMeshAgent.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshAgent.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshAgent.enabled|bool|true|Enables or disables creation of the operator deployment/service|
