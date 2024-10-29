package generate

import (
	glooGen "github.com/solo-io/gloo/install/helm/gloo/generate"
	glooFedGen "github.com/solo-io/solo-projects/install/helm/gloo-fed/generate"
)

type HelmConfig struct {
	Config
	Global *GlobalConfig `json:"global,omitempty"`
}

type GlobalConfig struct {
	*glooGen.Global
	Stats      *GlooEEStats      `json:"stats,omitempty"`
	Extensions *GlooEeExtensions `json:"extensions,omitempty"`
	Graphql    *GraphqlOptions   `json:"graphql,omitempty" desc:"GraphQL configuration options."`
}

type GlooConfig struct {
	LicenseSecretName string `json:"license_secret_name" desc:"The name of a secret that contains your Gloo Edge license key. Set 'create_license_key' to 'false' to disable use of the default license secret."`
	Redis             *Redis `json:"redis,omitempty" desc:"These redis values should mirror those set at the top level. They share the same default values."`
	*glooGen.Config
}

type Config struct {
	Settings            *glooGen.Settings      `json:"settings,omitempty"`
	LicenseKey          string                 `json:"license_key,omitempty" desc:"Your Gloo Edge license key."`
	CreateLicenseSecret bool                   `json:"create_license_secret" desc:"Create a secret for the license specified in 'license_key'. Set to 'false' if you use 'license_secret_name' instead."`
	Gloo                *GlooConfig            `json:"gloo,omitempty"`
	Redis               *Redis                 `json:"redis,omitempty"`
	Observability       *Observability         `json:"observability,omitempty"`
	Rbac                *Rbac                  `json:"rbac"`
	Grafana             interface{}            `json:"grafana,omitempty"`
	Prometheus          interface{}            `json:"prometheus,omitempty"`
	PortalWebServer     interface{}            `json:"gateway-portal-web-server,omitempty"`
	Tags                map[string]string      `json:"tags,omitempty"`
	GlooFed             *glooFedGen.HelmConfig `json:"gloo-fed,omitempty"`
}

// Common

type Rbac struct {
	Create bool `json:"create"`
}

// Gloo-ee

type GlooEeExtensions struct {
	ExtAuth           *ExtAuth    `json:"extAuth,omitempty"`
	RateLimit         *RateLimit  `json:"rateLimit,omitempty"`
	ExtProc           interface{} `json:"extProc,omitempty" desc:"Global configuration for External Processing filter."`
	Caching           *Caching    `json:"caching,omitempty"`
	GlooRedis         *GlooRedis  `json:"glooRedis,omitempty"`
	DataPlanePerProxy *bool       `json:"dataPlanePerProxy,omitempty" desc:"If set to true, a distinct set of data-plane resources (ratelimit, extauth, redis, caching) will be created for each enabled gateway proxy and each gateway proxy will exclusively use its associated data-plane resources. Eg: If there are two gateway proxies defined, gw-ingress and gw-internal, two sets of data-plane resources will be created (ie: ratelimit-gw-ingress, extauth-gw-ingress, redis-gw-ingress and caching-gw-ingress to be used solely by gw-ingress and ratelimit-gw-internal, extauth-gw-internal, redis-gw-internal and caching-gw-internal to be used solely by gw-internal). This is useful in cases where it's desirable to completely isolate the data-planes across proxies. One such case is when proxies receive dramatically different levels of traffic. In that case, one might want to isolate the lower trafficked proxy's data-plane in order to prevent latency from competition for resources, while also allocating additional resources to the higher trafficked proxy's components. There may also be security reasons to want isolated data-planes. On the other hand, when set to false, only one set of data-plane resources (ie ratelimit, extauth, caching, redis) will be created and used by all proxies. Note that when set to true, each proxy will have to be manually configured to use the uniquely-named per-proxy services, including in the case where there is only one proxy enabled. Defaults to false."`
}

type GlooEEStats struct {
	*glooGen.Stats
	ServiceMonitor *PodServiceMonitor `json:"serviceMonitor,omitempty"`
	PodMonitor     *PodServiceMonitor `json:"podMonitor,omitempty"`
}

type PodServiceMonitor struct {
	ReleaseLabel *string `json:"releaseLabel,omitempty" desc:"The release label used for the Pod/Service Monitor (default prom)"`
}

type GlooRedis struct {
	EnableAcl *bool "json:\"enableAcl,omitempty\" desc:\"Whether to include the ACL policy on redis install. Set to `true` if you want to provide an external redis endpoint. If `redis.disabled` is set to `true`, you will have to create the redis secret, `redis`, to provide the password. The secret uses the key, `redis-password`, for the password value. Defaults to true.\""
}

type RateLimit struct {
	Enabled            bool                          `json:"enabled,omitempty" desc:"if true, deploy rate limit service (default true)"`
	ServerUpstreamName string                        `json:"serverUpstreamName" desc:"if set, this is the name of the upstream that we define in Settings to use as the target cluster in the rate_limit http filter. Default is rate-limit."`
	Deployment         *RateLimitDeployment          `json:"deployment,omitempty"`
	Service            *RateLimitService             `json:"service,omitempty"`
	Upstream           *glooGen.KubeResourceOverride `json:"upstream,omitempty"`
	CustomRateLimit    interface{}                   `json:"customRateLimit,omitempty"`
	BeforeAuth         bool                          `json:"beforeAuth,omitempty" desc:"If true, rate limiting checks occur before auth (default false). If gloo.settings.ratelimitServer is set, this value will be ignored."`
	Affinity           map[string]interface{}        `json:"affinity,omitempty" desc:"Affinity rules to be applied"`
	AntiAffinity       map[string]interface{}        `json:"antiAffinity,omitempty" desc:"Anti-affinity rules to be applied"`
}

type Caching struct {
	Enabled    *bool                         `json:"enabled,omitempty" desc:"if true, deploy caching service (default false)"`
	Name       string                        `json:"name" desc:"name for the service,omitempty"`
	Deployment *CachingDeployment            `json:"deployment,omitempty"`
	Upstream   *glooGen.KubeResourceOverride `json:"upstream,omitempty"`
	*glooGen.ServiceSpec
}

type CachingDeployment struct {
	Name                string                 `json:"name"`
	Image               *glooGen.Image         `json:"image,omitempty"`
	Stats               *glooGen.Stats         `json:"stats"`
	GlooAddress         string                 `json:"glooAddress"`
	RunAsUser           *float64               `json:"runAsUser" desc:"Explicitly set the user ID for the container to run as. Default is 10101"`
	FloatingUserId      *bool                  `json:"floatingUserId" desc:"set to true to allow the cluster to dynamically assign a user ID"`
	Affinity            map[string]interface{} `json:"affinity,omitempty" desc:"Affinity rules to be applied"`
	AntiAffinity        map[string]interface{} `json:"antiAffinity,omitempty" desc:"Anti-affinity rules to be applied"`
	ExtraCachingLabels  map[string]string      `json:"extraCachingLabels,omitempty" desc:"Optional extra key-value pairs to add to the spec.template.metadata.labels data of the Caching deployment."`
	LogLevel            *string                `json:"logLevel,omitempty" desc:"Level at which the pod should log. Options include \"info\", \"debug\", \"warn\", \"error\", \"panic\" and \"fatal\". Default level is info"`
	PodDisruptionBudget *PodDisruptionBudget   `json:"podDisruptionBudget,omitempty" desc:"PodDisruptionBudget is an object to define the max disruption that can be caused to the caching service pods."`
	*glooGen.DeploymentSpec
}

type DynamoDb struct {
	Region             string `json:"region" desc:"aws region to run DynamoDB requests in"`
	SecretName         string `json:"secretName,omitempty" desc:"name of the aws secret in gloo's installation namespace that has aws creds (if provided, uses DynamoDB to back rate-limiting service instead of Redis)"`
	RateLimitTableName string `json:"tableName" desc:"DynamoDB table name used to back rate limit service (default rate-limits)"`
	ConsistentReads    bool   `json:"consistentReads" desc:"if true, reads from DynamoDB will be strongly consistent (default false)"`
	BatchSize          uint8  `json:"batchSize" desc:"batch size for get requests to DynamoDB (max 100, default 100)"`
}

type AerospikeDb struct {
	Address      string        `json:"address" desc:"The IP address or hostname of the Aerospike database. The address must be reachable from Gloo Edge, such as in a virtual machine with a public IP address or in a pod in the cluster. By setting this value, you also enable Aerospike database as the backing storage for the rate limit service."`
	Namespace    string        `json:"namespace" desc:"The Aerospike namespace of the database."`
	Set          string        `json:"set" desc:"The Aerospike name of the database set."`
	Port         int           "json:\"port\" desc:\"The port of the `rateLimit.deployment.aerospike.address`.\""
	BatchSize    int           `json:"batchSize" desc:"The size of the batch, which is the number of keys sent in the request."`
	CommitLevel  int           `json:"commitLevel" desc:"The level of guaranteed consistency for transaction commits on the Aerospike server. For possible values, see the [Aerospike commit policy](https://github.com/aerospike/aerospike-client-go/blob/master/commit_policy.go)."`
	ReadModeSC   int           `json:"readModeSC" desc:"The read mode for strong consistency (SC) options. For possible values, see the [Aerospike read mode SC](https://github.com/aerospike/aerospike-client-go/blob/master/read_mode_sc.go)."`
	ReadModeAP   int           `json:"readModeAP" desc:"The read mode for availability (AP). For possible values, see the [Aerospike read mode AP](https://github.com/aerospike/aerospike-client-go/blob/master/read_mode_ap.go)."`
	AerospikeTLS *AerospikeTLS `json:"tls,omitempty" desc:"Aerospike TLS Settings"`
}

type AerospikeTLS struct {
	Name             string   "json:\"name,omitempty\" desc:\"The subject name of the TLS authority. For more information, see the [Aerospike docs](https://docs.aerospike.com/reference/configuration#tls-name). To enable TLS, you must provide at least this value and the `certSecretName` value.\""
	Version          string   `json:"version,omitempty" desc:"The TLS version. Versions 1.0, 1.1, 1.2, and 1.3 are supported."`
	Insecure         *bool    "json:\"insecure,omitempty\" desc:\"The TLS insecure setting. If set to `true`, the authority of the certificate on the client's end is not authenticated. You might use insecure mode in non-production environments when the certificate is not known.\""
	CertSecretName   string   "json:\"certSecretName,omitempty\" desc:\"The name of the `kubernetes.io/tls` secret that has the `tls.crt` and `tls.key` data. To enable TLS, you must provide at least this value and the `name` value.\""
	RootCASecretName string   "json:\"rootCASecretName,omitempty\" desc:\"The secret name for the Opaque root CA that sets the key as `tls.crt`.\""
	CurveGroups      []string `json:"curveGroups,omitempty" desc:"The TLS identifier for an elliptic curve. For more information, see [TLS supported groups](https://www.iana.org/assignments/tls-parameters/tls-parameters.xml#tls-parameters-8)."`
}

type RateLimitDeployment struct {
	Name                 string                      `json:"name"`
	GlooAddress          string                      `json:"glooAddress"`
	GlooPort             uint                        `json:"glooPort" desc:"Sets the port of the gloo xDS server in the ratelimit sidecar envoy bootstrap config"`
	DynamoDb             DynamoDb                    `json:"dynamodb"`
	AerospikeDb          AerospikeDb                 `json:"aerospike"`
	Stats                *glooGen.Stats              `json:"stats"`
	RunAsUser            float64                     `json:"runAsUser" desc:"Explicitly set the user ID for the container to run as in the podSecurityContext. Default is 10101. If podSecurityContext is defined, this value is not applied."`
	LivenessProbeEnabled *bool                       `json:"livenessProbeEnabled,omitempty" desc:"Set to true to enable a liveness probe for RateLimit (default is false)."`
	FloatingUserId       bool                        `json:"floatingUserId" desc:"set to true to allow the cluster to dynamically assign a user ID in the podSecurityContext. If podSecurityContext is defined, this value is not applied."`
	ExtraRateLimitLabels map[string]string           `json:"extraRateLimitLabels,omitempty" desc:"Optional extra key-value pairs to add to the spec.template.metadata.labels data of the rateLimit deployment."`
	LogLevel             *string                     `json:"logLevel,omitempty" desc:"Level at which the pod should log. Options include \"info\", \"debug\", \"warn\", \"error\", \"panic\" and \"fatal\". Default level is info."`
	PodDisruptionBudget  *PodDisruptionBudget        `json:"podDisruptionBudget,omitempty" desc:"PodDisruptionBudget is an object to define the max disruption that can be caused to the rate-limit pods."`
	PodSecurityContext   *glooGen.PodSecurityContext `json:"podSecurityContext,omitempty" desc:"podSecurityContext for the pod. If this is defined it supercedes any values set in FloatingUserId or RunAsUser. See [pod security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#podsecuritycontext-v1-core) for details."`
	*glooGen.KubeResourceOverride
	*glooGen.DeploymentSpec
	*RateLimitDeploymentContainer
}

type RateLimitDeploymentContainer struct {
	RateLimitContainerSecurityContext *glooGen.SecurityContext `json:"rateLimitContainerSecurityContext,omitempty" desc:"securityContext for rate limit container. See [security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#securitycontext-v1-core) for details"`
	Image                             *glooGen.Image           `json:"image,omitempty"`
}

type RateLimitService struct {
	Port uint   `json:"port"`
	Name string `json:"name"`
	*glooGen.KubeResourceOverride
}

type Redis struct {
	Deployment                *RedisDeployment `json:"deployment,omitempty"`
	Service                   *RedisService    `json:"service,omitempty"`
	TlsEnabled                bool             `json:"tlsEnabled,omitempty" desc:"Enables tls for redis. Default is false."`
	Cert                      *RedisCert       `json:"cert,omitempty"`
	ClientSideShardingEnabled bool             `json:"clientSideShardingEnabled" desc:"If set to true, Envoy will be used as a Redis proxy and load balance requests between redis instances scaled via replicas. Default is false."`
	Disabled                  bool             "json:\"disabled\" desc:\"If set to true, Redis service creation will be blocked. When set to `true` when `global.extensions.glooRedis.enableAcl` is set to `true` as well, the `redis` secret will not be created. The client you will have to create the secret to provide the password, the key used for the password is `redis-password`. Default is false.\""
	Clustered                 bool             `json:"clustered" desc:"If true, we create the correct client to handle clustered redis. Default is false"`
	AclPrefix                 *string          `json:"aclPrefix,omitempty" desc:"The ACL policy for the default redis user. This is the prefix only, and if overridden, should end with < to signal the password."`
}

type RedisMountCert struct {
	SecretName string `json:"secretName" desc:"This is the name to the Opaque kubernetes secret containing the cert. The secret data key names should be 'ca.crt', 'tls.crt', and 'tls.key'."`
	MountPath  string `json:"mountPath" desc:"Path used to mount the secret. This should be a unique path, for each secret."`
}

type RedisInitContainer struct {
	Image           *glooGen.Image           `json:"image,omitempty"`
	SecurityContext *glooGen.SecurityContext `json:"securityContext,omitempty" desc:"securityContext for the redis init container. See [security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#securitycontext-v1-core) for details."`
}

type RedisDeployment struct {
	InitContainer            *RedisInitContainer         `json:"initContainer,omitempty" desc:"Override the image used in the initContainer."`
	Name                     string                      `json:"name"`
	StaticPort               uint                        `json:"staticPort"`
	RunAsUser                float64                     `json:"runAsUser" desc:"Explicitly set the user ID for the container to run as in the podSecurityContext. Default is 999. If a podSecurityContext is defined for the pod , this value is not applied."`
	RunAsGroup               float64                     `json:"runAsGroup" desc:"Explicitly set the group ID for the container to run as in the podSecurityContext. Default is 999. If a podSecurityContext is defined for the pod, this value is not applied."`
	FsGroup                  float64                     `json:"fsGroup" desc:"Explicitly set the fsGroup ID for the container to run as in the podSecurityContext. Default is 999. If a podSecurityContext is defined for the pod, this value is not applied."`
	FloatingUserId           bool                        `json:"floatingUserId" desc:"set to true to allow the cluster to dynamically assign a user ID. If podSecurityContext is defined, this value is not applied."`
	ExtraRedisLabels         map[string]string           `json:"extraRedisLabels,omitempty" desc:"Optional extra key-value pairs to add to the spec.template.metadata.labels data of the redis deployment."`
	EnablePodSecurityContext *bool                       `json:"enablePodSecurityContext,omitempty" desc:"Whether or not to render the pod security context. Default is true."`
	PodSecurityContext       *glooGen.PodSecurityContext `json:"podSecurityContext,omitempty" desc:"podSecurityContext for the pod. If this is defined it supercedes any values set in FloatingUserId, RunAsUser, RunAsGroup or FsGroup. See [pod security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#podsecuritycontext-v1-core) for details."`
	*glooGen.DeploymentSpec
	*glooGen.KubeResourceOverride
	*RedisDeploymentContainer
}

type RedisDeploymentContainer struct {
	RedisContainerSecurityContext *glooGen.SecurityContext `json:"redisContainerSecurityContext,omitempty" desc:"securityContext for the redis container. See [security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#securitycontext-v1-core) for details."`
	Image                         *glooGen.Image           `json:"image,omitempty"`
}

type RedisService struct {
	Port uint   `json:"port" desc:"This is the port set for the redis service."`
	Name string `json:"name" desc:"This is the name of the redis service. If there is an external service, this can be used to set the endpoint of the external service.  Set redis.disabled if setting the value of the redis service."`
	DB   uint   `json:"db" desc:"This is the db number of the redis service, can be any int from 0 to 15, this field ignored when using clustered redis or when ClientSideShardingEnabled is true "`
	*glooGen.KubeResourceOverride
}

type RedisCert struct {
	Enabled bool   `json:"enabled" desc:"If set to true, a secret for redis will be created, and cert.crt and cert.key will be required. If redis.disabled is not set the socket type is set to tsl. If redis.disabled is set, then only a secret will be created containing the cert and key. The secret is mounted to the rate-limiter and redis deployments with the cert and key. Default is false."`
	Crt     string `json:"crt" desc:"TLS certificate. If CACert is not provided, this will be used as the CA cert as well as the TLS cert for the redis server."`
	Key     string `json:"key" desc:"TLS certificate key."`
	CaCrt   string `json:"cacrt" desc:"Optional. CA certificate."`
	*glooGen.KubeResourceOverride
}

type Observability struct {
	Enabled                   bool                          `json:"enabled,omitempty" desc:"if true, deploy observability service (default true)"`
	Deployment                *ObservabilityDeployment      `json:"deployment,omitempty"`
	CustomGrafana             *CustomGrafana                `json:"customGrafana" desc:"Configure a custom grafana deployment to work with Gloo observability, rather than the default Gloo grafana"`
	UpstreamDashboardTemplate string                        `json:"upstreamDashboardTemplate" desc:"Provide a custom dashboard template to use when generating per-upstream dashboards. The only variables available for use in this template are: {{.Uid}} and {{.EnvoyClusterName}}. Recommended to use Helm's --set-file to provide this value."`
	Rbac                      *glooGen.KubeResourceOverride `json:"rbac,omitempty"`
	ServiceAccount            *glooGen.KubeResourceOverride `json:"serviceAccount,omitempty"`
	ConfigMap                 *glooGen.KubeResourceOverride `json:"configMap,omitempty"`
	Secret                    *glooGen.KubeResourceOverride `json:"secret,omitempty"`
}

type ObservabilityDeployment struct {
	Image                    *glooGen.Image    `json:"image,omitempty"`
	Stats                    *glooGen.Stats    `json:"stats"`
	RunAsUser                float64           `json:"runAsUser" desc:"Explicitly set the user ID for the container to run as. Default is 10101"`
	FloatingUserId           bool              `json:"floatingUserId" desc:"set to true to allow the cluster to dynamically assign a user ID"`
	ExtraObservabilityLabels map[string]string `json:"extraObservabilityLabels,omitempty" desc:"Optional extra key-value pairs to add to the spec.template.metadata.labels data of the Observability deployment."`
	LogLevel                 *string           `json:"logLevel,omitempty" desc:"Level at which the pod should log. Options include \"info\", \"debug\", \"warn\", \"error\", \"panic\" and \"fatal\". Default level is info"`

	*glooGen.DeploymentSpec
	*glooGen.KubeResourceOverride
}

type CustomGrafana struct {
	Enabled    bool   `json:"enabled,omitempty" desc:"Set to true to indicate that the observability pod should talk to a custom grafana instance"`
	Username   string `json:"username,omitempty" desc:"Set this and the 'password' field to authenticate to the custom grafana instance using basic auth"`
	Password   string `json:"password,omitempty" desc:"Set this and the 'username' field to authenticate to the custom grafana instance using basic auth"`
	ApiKey     string `json:"apiKey,omitempty" desc:"Authenticate to the custom grafana instance using this api key"`
	Url        string `json:"url,omitempty" desc:"The URL for the custom grafana instance"`
	CaBundle   string `json:"caBundle,omitempty" desc:"The Certificate Authority used to verify the server certificates."`
	DataSource string `json:"dataSource,omitempty" desc:"The data source for Gloo-generated dashboards to point to; defaults to null (ie Grafana's default data source)'"`
	*glooGen.KubeResourceOverride
}

type ExtAuth struct {
	Enabled              bool                           `json:"enabled,omitempty" desc:"if true, deploy ExtAuth service (default true)"`
	UserIdHeader         string                         `json:"userIdHeader,omitempty"`
	Deployment           *ExtAuthDeployment             `json:"deployment,omitempty"`
	Service              *ExtAuthService                `json:"service,omitempty"`
	SigningKey           *ExtAuthSigningKey             `json:"signingKey,omitempty"`
	TlsEnabled           bool                           `json:"tlsEnabled" desc:"if true, have extauth terminate TLS itself (whereas Gloo mTLS mode runs an Envoy and SDS sidecars to do TLS termination and cert rotation)"`
	SecretName           *string                        `json:"secretName" desc:"the name of the tls secret used to secure connections to the extauth service"`
	CertPath             string                         `json:"certPath,omitempty" desc:"location of tls termination cert, if omitted defaults to /etc/envoy/ssl/tls.crt"`
	KeyPath              string                         `json:"keyPath,omitempty" desc:"location of tls termination key, if omitted defaults to /etc/envoy/ssl/tls.key"`
	Plugins              map[string]*ExtAuthPlugin      `json:"plugins,omitempty"`
	EnvoySidecar         bool                           `json:"envoySidecar" desc:"if true, deploy ExtAuth as a sidecar with envoy (defaults to false)"`
	StandaloneDeployment bool                           `json:"standaloneDeployment" desc:"if true, create a standalone ExtAuth deployment (defaults to true)"`
	ServerUpstreamName   string                         `json:"serverUpstreamName" desc:"if set, this is the name of the upstream that we define in Settings to use as the target cluster in the ext_authz http filter. If not set, the name 'extauth' (if 'standaloneDeployment' is true) or 'extauth-sidecar' (if 'standaloneDeployment' is false) will be used."`
	TransportApiVersion  string                         `json:"transportApiVersion" desc:"Determines the API version for the ext_authz transport protocol that will be used by Envoy to communicate with the auth server. Defaults to 'V3''"`
	ServiceName          string                         `json:"serviceName,omitempty"`
	RequestTimeout       string                         `json:"requestTimeout,omitempty" desc:"Timeout for the ext auth service to respond (defaults to 200ms)"`
	HeadersToRedact      string                         `json:"headersToRedact,omitempty" desc:"Space separated list of headers to redact from the logs. To avoid the default redactions, specify '-' as the value"`
	Secret               *glooGen.KubeResourceOverride  `json:"secret,omitempty"`
	Upstream             *glooGen.KubeResourceOverride  `json:"upstream,omitempty"`
	RequestBody          *BufferSettings                `json:"requestBody,omitempty" desc:"Set in order to send the body of the request, and not just the headers"`
	Affinity             map[string]interface{}         `json:"affinity,omitempty" desc:"Affinity rules to be applied. If unset, require extAuth pods to be scheduled on nodes with already-running gateway-proxy pods"`
	AntiAffinity         map[string]interface{}         `json:"antiAffinity,omitempty" desc:"Anti-affinity rules to be applied"`
	NamedExtAuth         map[string]glooGen.ResourceRef `json:"namedExtAuth,omitempty" desc:"Settings to configure additional external auth servers"`
}

type ExtAuthDeployment struct {
	Name                 string                   `json:"name"`
	GlooAddress          string                   `json:"glooAddress,omitempty"`
	GlooPort             uint                     `json:"glooPort" desc:"Sets the port of the gloo xDS server in the ratelimit sidecar envoy bootstrap config"`
	Port                 uint                     `json:"port"`
	Image                *glooGen.Image           `json:"image,omitempty"`
	Stats                *glooGen.Stats           `json:"stats"`
	RunAsUser            float64                  `json:"runAsUser" desc:"Explicitly set the user ID for the container to run as. Default is 10101"`
	LivenessProbeEnabled *bool                    `json:"livenessProbeEnabled,omitempty" desc:"Set to true to enable a liveness probe for ExtAuth (default is false)."`
	FsGroup              float64                  `json:"fsGroup" desc:"Explicitly set the group ID for volume ownership. Default is 10101"`
	FloatingUserId       bool                     `json:"floatingUserId" desc:"set to true to allow the cluster to dynamically assign a user ID"`
	ExtraExtAuthLabels   map[string]string        `json:"extraExtAuthLabels,omitempty" desc:"Optional extra key-value pairs to add to the spec.template.metadata.labels data of the ExtAuth deployment."`
	ExtraVolume          []map[string]interface{} `json:"extraVolume,omitempty" desc:"custom defined yaml for allowing extra volume on the extauth container"`
	ExtraVolumeMount     []map[string]interface{} `json:"extraVolumeMount,omitempty" desc:"custom defined yaml for allowing extra volume mounts on the extauth container"`
	PodDisruptionBudget  *PodDisruptionBudget     `json:"podDisruptionBudget,omitempty" desc:"PodDisruptionBudget is an object to define the max disruption that can be caused to the ExtAuth pods"`
	Redis                *ExtAuthRedisConfig      `json:"redis,omitempty" desc:"this is the redis configurations."`
	LogLevel             *string                  `json:"logLevel,omitempty" desc:"Level at which the pod should log. Options include \"info\", \"debug\", \"warn\", \"error\", \"panic\" and \"fatal\". Default level is info"`
	LogToFileLocation    string                   `json:"logToFileLocation,omitempty" desc:"If set, the extauth pod will log to this file instead of stdout"`
	*glooGen.DeploymentSpec
	*glooGen.KubeResourceOverride
}

type ExtAuthRedisConfig struct {
	Certs *[]RedisMountCert `json:"certs,omitempty" desc:"Secrets that contain the TLS certificates."`
}

type ExtAuthService struct {
	Port uint   `json:"port"`
	Name string `json:"name"`
	*glooGen.KubeResourceOverride
}

type ExtAuthSigningKey struct {
	Name       string `json:"name"`
	SigningKey string `json:"signing-key"`
}

type ExtAuthPlugin struct {
	Image *glooGen.Image `json:"image,omitempty"`
}

type BufferSettings struct {
	MaxRequestBytes     uint32 `json:"maxRequestBytes,omitempty" desc:"Sets the maximum size of a message body that the filter will hold in memory, returning 413 and *not* initiating the authorization process when reaching the maximum (defaults to 4KB)"`
	AllowPartialMessage bool   `json:"allowPartialMessage,omitempty" desc:"if true, Envoy will buffer the message until max_request_bytes is reached, dispatch the authorization request, and not return an error"`
	PackAsBytes         bool   `json:"packAsBytes,omitempty" desc:"if true, Envoy will send the body sent to the external authorization service with raw bytes"`
}

type OAuth struct {
	Server string `json:"server"`
	Client string `json:"client"`
}

type PodDisruptionBudget struct {
	MinAvailable   int32 `json:"minAvailable,omitempty" desc:"An eviction is allowed if at least \"minAvailable\" pods selected by \"selector\" will still be available after the eviction, i.e. even in the absence of the evicted pod. So for example you can prevent all voluntary evictions by specifying \"100%\"."`
	MaxUnavailable int32 `json:"maxUnavailable,omitempty" desc:"An eviction is allowed if at most \"maxUnavailable\" pods selected by \"selector\" are unavailable after the eviction, i.e. even in absence of the evicted pod. For example, one can prevent all voluntary evictions by specifying 0. This is a mutually exclusive setting with \"minAvailable\"."`
}

type GraphqlOptions struct {
	ChangeValidation *GraphqlChangeValidationOptions `json:"changeValidation,omitempty" desc:"Options for validating GraphQL schema updates."`
}

type GraphqlChangeValidationOptions struct {
	RejectBreaking *bool                         `json:"rejectBreaking,omitempty" desc:"Whether to reject breaking GraphQL schema updates (default false)."`
	Rules          *GraphqlChangeValidationRules `json:"rules,omitempty" desc:"GraphQL Inspector processing rules."`
}

type GraphqlChangeValidationRules struct {
	DangerousToBreaking             *bool `json:"dangerousToBreaking,omitempty" desc:"Whether the RULE_DANGEROUS_TO_BREAKING processing rule is enabled (default false)."`
	DeprecatedFieldRemovalDangerous *bool `json:"deprecatedFieldRemovalDangerous,omitempty" desc:"Whether the RULE_DEPRECATED_FIELD_REMOVAL_DANGEROUS processing rule is enabled (default false)."`
	IgnoreDescriptionChanges        *bool `json:"ignoreDescriptionChanges,omitempty" desc:"Whether the RULE_IGNORE_DESCRIPTION_CHANGES processing rule is enabled (default false)."`
	IgnoreUnreachable               *bool `json:"ignoreUnreachable,omitempty" desc:"Whether the RULE_IGNORE_UNREACHABLE processing rule is enabled (default false)."`
}
