source ~/bin/gloo-mesh-license-env
source ./env-workshop.sh

export GLOO_MESH_LICENSE_KEY=${GLOO_MESH_LICENSE}
#export GM_VERSION=2.1.0-beta5
# How to enable the Cilium components in the UI
# window.localStorage.setItem('cilium-enabled', 'true')
export GM_VERSION=v2.3.0-rc2



# NOTE: for this demo, and revisions, we are
# assuming **** Istio 1.11.7 ****
ISTIO_ROOT_DIR="/home/solo/dev/istio/latest"

#This how to download istio: 
#curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.18.0-alpha.0 sh -


../scripts/deploy.sh 1 mgmt
../scripts/deploy.sh 2 cluster1 us-west us-west-1
../scripts/deploy.sh 3 cluster2 us-east us-east-2

../scripts/check.sh $MGMT kube-system
../scripts/check.sh $MGMT metallb-system
../scripts/check.sh $CLUSTER1 kube-system
../scripts/check.sh $CLUSTER1 metallb-system
../scripts/check.sh $CLUSTER2 kube-system
../scripts/check.sh $CLUSTER2 metallb-system

kubectl config use-context ${MGMT}


helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise 
helm repo update
kubectl --context ${MGMT} create ns gloo-mesh 

helm upgrade --install gloo-mesh-enterprise https://storage.googleapis.com/gloo-platform-dev/helm-charts/gloo-mesh-enterprise/gloo-mesh-enterprise-2.4.0-beta0-2023-04-14-ambient-b340830d5.tgz \
--namespace gloo-mesh --kube-context ${MGMT} \
--version=${GM_VERSION} \
--set glooMeshMgmtServer.ports.healthcheck=8091 \
--set legacyMetricsPipeline.enabled=false \
--set telemetryGateway.enabled=true \
--set telemetryGateway.service.type=LoadBalancer \
--set telemetryCollector.image.repository=gcr.io/solo-test-236622/gloo-platform-dev/gloo-otel-collector \
--set telemetryGateway.image.repository=gcr.io/solo-test-236622/gloo-platform-dev/gloo-otel-collector \
--set glooMeshUi.serviceType=LoadBalancer \
--set experimental.ambientEnabled=true \
--set mgmtClusterName=mgmt \
--set global.cluster=mgmt \
--set licenseKey=${GLOO_MESH_LICENSE_KEY}

kubectl --context ${MGMT} -n gloo-mesh rollout status deploy/gloo-mesh-mgmt-server

../scripts/check.sh $MGMT gloo-mesh



export ENDPOINT_GLOO_MESH=$(kubectl --context ${MGMT} -n gloo-mesh get svc gloo-mesh-mgmt-server -o jsonpath='{.status.loadBalancer.ingress[0].*}'):9900
export HOST_GLOO_MESH=$(echo ${ENDPOINT_GLOO_MESH} | cut -d: -f1)
export ENDPOINT_TELEMETRY_GATEWAY=$(kubectl --context ${MGMT} -n gloo-mesh get svc gloo-telemetry-gateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):4317


../scripts/check.sh $MGMT gloo-mesh

helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

kubectl apply --context ${MGMT} -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: KubernetesCluster
metadata:
  name: cluster1
  namespace: gloo-mesh
spec:
  clusterDomain: cluster.local
EOF

kubectl --context ${CLUSTER1} create ns gloo-mesh

kubectl get secret relay-root-tls-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl create secret generic relay-root-tls-secret -n gloo-mesh --context $CLUSTER1 --from-file ca.crt=ca.crt
rm ca.crt

kubectl get secret relay-identity-token-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.token}' | base64 -d > token
kubectl create secret generic relay-identity-token-secret -n gloo-mesh --context $CLUSTER1 --from-file token=token
rm token


helm upgrade --install gloo-mesh-agent https://storage.googleapis.com/gloo-platform-dev/helm-charts/gloo-mesh-agent/gloo-mesh-agent-2.4.0-beta0-2023-04-14-ambient-b340830d5.tgz \
  --namespace gloo-mesh \
  --kube-context=${CLUSTER1} \
  --set relay.serverAddress=${ENDPOINT_GLOO_MESH} \
  --set relay.authority=gloo-mesh-mgmt-server.gloo-mesh \
  --set rate-limiter.enabled=false \
  --set ext-auth-service.enabled=false \
  --set glooMeshPortalServer.enabled=false \
  --set cluster=$CLUSTER1 \
  --set telemetryCollector.enabled=true \
  --set telemetryCollector.config.exporters.otlp.endpoint=\"${ENDPOINT_TELEMETRY_GATEWAY}\" \
  --set telemetryCollector.image.repository=gcr.io/solo-test-236622/gloo-platform-dev/gloo-otel-collector \
  --version ${GM_VERSION}  


  kubectl apply --context ${MGMT} -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: KubernetesCluster
metadata:
  name: cluster2
  namespace: gloo-mesh
spec:
  clusterDomain: cluster.local
EOF

kubectl --context ${CLUSTER2} create ns gloo-mesh

kubectl get secret relay-root-tls-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl create secret generic relay-root-tls-secret -n gloo-mesh --context $CLUSTER2 --from-file ca.crt=ca.crt
rm ca.crt

kubectl get secret relay-identity-token-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.token}' | base64 -d > token
kubectl create secret generic relay-identity-token-secret -n gloo-mesh --context $CLUSTER2 --from-file token=token
rm token

helm upgrade --install gloo-mesh-agent https://storage.googleapis.com/gloo-platform-dev/helm-charts/gloo-mesh-agent/gloo-mesh-agent-2.4.0-beta0-2023-04-14-ambient-b340830d5.tgz \
  --namespace gloo-mesh \
  --kube-context=${CLUSTER2} \
  --set relay.serverAddress=${ENDPOINT_GLOO_MESH} \
  --set relay.authority=gloo-mesh-mgmt-server.gloo-mesh \
  --set rate-limiter.enabled=false \
  --set ext-auth-service.enabled=false \
  --set glooMeshPortalServer.enabled=false \
  --set cluster=$CLUSTER2 \
  --set telemetryCollector.enabled=true \
  --set telemetryCollector.config.exporters.otlp.endpoint=\"${ENDPOINT_TELEMETRY_GATEWAY}\" \
  --set telemetryCollector.image.repository=gcr.io/solo-test-236622/gloo-platform-dev/gloo-otel-collector \
  --version ${GM_VERSION}  

#echo "check agents enter to cont..."
../scripts/check.sh $CLUSTER1 gloo-mesh  
../scripts/check.sh $CLUSTER2 gloo-mesh  
#read -s

pod=$(kubectl --context ${MGMT} -n gloo-mesh get pods -l app=gloo-mesh-mgmt-server -o jsonpath='{.items[0].metadata.name}')
kubectl --context ${MGMT} -n gloo-mesh debug -it ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl http://localhost:9091/metrics | grep relay_push_clients_connected

## Set up a global workspace settings to control east-west gateway selector
## TODO:ceposta we may remove this and put it into the git repo....
kubectl apply --context ${MGMT} -f - <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: WorkspaceSettings
metadata:
  name: global
  namespace: gloo-mesh
spec:
  options:
    eastWestGateways:
      - selector:
          labels:
            istio: eastwestgateway
EOF


#### Installing sample apps (cluster 1)
curl https://raw.githubusercontent.com/istio/istio/release-1.16/samples/bookinfo/platform/kube/bookinfo.yaml > bookinfo.yaml

kubectl --context ${CLUSTER1} create ns bookinfo-frontends
kubectl --context ${CLUSTER1} create ns bookinfo-backends
kubectl --context ${CLUSTER1} label namespace bookinfo-frontends istio.io/dataplane-mode=ambient
kubectl --context ${CLUSTER1} label namespace bookinfo-backends istio.io/dataplane-mode=ambient

# deploy the frontend bookinfo service in the bookinfo-frontends namespace
kubectl --context ${CLUSTER1} -n bookinfo-frontends apply -f bookinfo.yaml -l 'account in (productpage)'
kubectl --context ${CLUSTER1} -n bookinfo-frontends apply -f bookinfo.yaml -l 'app in (productpage)'
kubectl --context ${CLUSTER1} -n bookinfo-backends apply -f bookinfo.yaml -l 'account in (reviews,ratings,details)'
# deploy the backend bookinfo services in the bookinfo-backends namespace for all versions less than v3
kubectl --context ${CLUSTER1} -n bookinfo-backends apply -f bookinfo.yaml -l 'app in (reviews,ratings,details),version notin (v3)'
# Update the productpage deployment to set the environment variables to define where the backend services are running
kubectl --context ${CLUSTER1} -n bookinfo-frontends set env deploy/productpage-v1 DETAILS_HOSTNAME=details.bookinfo-backends.svc.cluster.local
kubectl --context ${CLUSTER1} -n bookinfo-frontends set env deploy/productpage-v1 REVIEWS_HOSTNAME=reviews.bookinfo-backends.svc.cluster.local
# Update the reviews service to display where it is coming from
kubectl --context ${CLUSTER1} -n bookinfo-backends set env deploy/reviews-v1 CLUSTER_NAME=${CLUSTER1}
kubectl --context ${CLUSTER1} -n bookinfo-backends set env deploy/reviews-v2 CLUSTER_NAME=${CLUSTER1}


#### Installing sample apps (cluster 2)
kubectl --context ${CLUSTER2} create ns bookinfo-frontends
kubectl --context ${CLUSTER2} create ns bookinfo-backends
kubectl --context ${CLUSTER2} label namespace bookinfo-frontends istio.io/dataplane-mode=ambient
kubectl --context ${CLUSTER2} label namespace bookinfo-backends istio.io/dataplane-mode=ambient

# deploy the frontend bookinfo service in the bookinfo-frontends namespace
kubectl --context ${CLUSTER2} -n bookinfo-frontends apply -f bookinfo.yaml -l 'account in (productpage)'
kubectl --context ${CLUSTER2} -n bookinfo-frontends apply -f bookinfo.yaml -l 'app in (productpage)'
kubectl --context ${CLUSTER2} -n bookinfo-backends apply -f bookinfo.yaml -l 'account in (reviews,ratings,details)'
# deploy the backend bookinfo services in the bookinfo-backends namespace for all versions
  kubectl --context ${CLUSTER2} -n bookinfo-backends apply -f bookinfo.yaml -l 'app in (reviews,ratings,details)'
# Update the productpage deployment to set the environment variables to define where the backend services are running
kubectl --context ${CLUSTER2} -n bookinfo-frontends set env deploy/productpage-v1 DETAILS_HOSTNAME=details.bookinfo-backends.svc.cluster.local
kubectl --context ${CLUSTER2} -n bookinfo-frontends set env deploy/productpage-v1 REVIEWS_HOSTNAME=reviews.bookinfo-backends.svc.cluster.local
# Update the reviews service to display where it is coming from
kubectl --context ${CLUSTER2} -n bookinfo-backends set env deploy/reviews-v1 CLUSTER_NAME=${CLUSTER2}
kubectl --context ${CLUSTER2} -n bookinfo-backends set env deploy/reviews-v2 CLUSTER_NAME=${CLUSTER2}
kubectl --context ${CLUSTER2} -n bookinfo-backends set env deploy/reviews-v3 CLUSTER_NAME=${CLUSTER2}
##### End sample apps

########## Install Gloo Addons
kubectl --context ${CLUSTER1} create namespace gloo-mesh-addons
kubectl --context ${CLUSTER1} label namespace gloo-mesh-addons istio.io/dataplane-mode=ambient
kubectl --context ${CLUSTER2} create namespace gloo-mesh-addons
kubectl --context ${CLUSTER2} label namespace gloo-mesh-addons istio.io/dataplane-mode=ambient


helm upgrade --install gloo-mesh-agent-addons https://storage.googleapis.com/gloo-platform-dev/helm-charts/gloo-mesh-agent/gloo-mesh-agent-2.4.0-beta0-2023-04-14-ambient-b340830d5.tgz \
  --namespace gloo-mesh-addons \
  --kube-context=${CLUSTER1} \
  --set cluster=cluster1 \
  --set glooMeshAgent.enabled=false \
  --set glooMeshPortalServer.enabled=true \
  --set glooMeshPortalServer.apiKeyStorage.config.host="redis.gloo-mesh-addons:6379" \
  --set glooMeshPortalServer.apiKeyStorage.configPath="/etc/redis/config.yaml" \
  --set glooMeshPortalServer.apiKeyStorage.secretKey="ThisIsSecret" \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true \
  --version ${GM_VERSION}


helm upgrade --install gloo-mesh-agent-addons https://storage.googleapis.com/gloo-platform-dev/helm-charts/gloo-mesh-agent/gloo-mesh-agent-2.4.0-beta0-2023-04-14-ambient-b340830d5.tgz \
  --namespace gloo-mesh-addons \
  --kube-context=${CLUSTER2} \
  --set cluster=cluster2 \
  --set glooMeshAgent.enabled=false \
  --set glooMeshPortalServer.enabled=true \
  --set glooMeshPortalServer.apiKeyStorage.config.host="redis.gloo-mesh-addons:6379" \
  --set glooMeshPortalServer.apiKeyStorage.configPath="/etc/redis/config.yaml" \
  --set glooMeshPortalServer.apiKeyStorage.secretKey="ThisIsSecret" \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true \
  --version ${GM_VERSION}

../scripts/check.sh $CLUSTER1 gloo-mesh-addons  
../scripts/check.sh $CLUSTER2 gloo-mesh-addons  

##################################################
##### Install Istio ##############################
##################################################

kubectl --context ${CLUSTER1} create ns istio-system
kubectl --context ${CLUSTER1} create ns istio-gateways

kubectl --context ${CLUSTER2} create ns istio-system
kubectl --context ${CLUSTER2} create ns istio-gateways

# create certs for https endpoints
kubectl --context ${CLUSTER1} -n istio-gateways create secret generic tls-secret \
--from-file=tls.key=./certs/tls.key \
--from-file=tls.crt=./certs/tls.crt

kubectl --context ${CLUSTER2} -n istio-gateways create secret generic tls-secret \
--from-file=tls.key=./certs/tls.key \
--from-file=tls.crt=./certs/tls.crt

##### Install Istio with Lifecycle####################

### Install Gateway SVs
registry=localhost:5000
kubectl --context ${CLUSTER1} create ns istio-gateways
kubectl --context ${CLUSTER1} label namespace istio-gateways istio-injection=enabled --overwrite

kubectl apply --context ${CLUSTER1} -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istio-ingressgateway
    istio: ingressgateway
  name: istio-ingressgateway
  namespace: istio-gateways
spec:
  ports:
  - name: http2
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
  type: LoadBalancer
EOF

kubectl apply --context ${CLUSTER1} -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istio-ingressgateway
    istio: eastwestgateway
    topology.istio.io/network: cluster1
  name: istio-eastwestgateway
  namespace: istio-gateways
spec:
  ports:
  - name: status-port
    port: 15021
    protocol: TCP
    targetPort: 15021
  - name: tls
    port: 15443
    protocol: TCP
    targetPort: 15443
  - name: hbone
    port: 15008
    protocol: TCP
    targetPort: 15008
  - name: https
    port: 16443
    protocol: TCP
    targetPort: 16443
  - name: tcp-istiod
    port: 15012
    protocol: TCP
    targetPort: 15012
  - name: tcp-webhook
    port: 15017
    protocol: TCP
    targetPort: 15017
  selector:
    app: istio-ingressgateway
    istio: eastwestgateway
    topology.istio.io/network: cluster1
  type: LoadBalancer
EOF

kubectl --context ${CLUSTER2} create ns istio-gateways
kubectl --context ${CLUSTER2} label namespace istio-gateways istio-injection=enabled --overwrite

kubectl apply --context ${CLUSTER2} -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istio-ingressgateway
    istio: ingressgateway
  name: istio-ingressgateway
  namespace: istio-gateways
spec:
  ports:
  - name: http2
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
  type: LoadBalancer
EOF

kubectl apply --context ${CLUSTER2} -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istio-ingressgateway
    istio: eastwestgateway
    topology.istio.io/network: cluster2
  name: istio-eastwestgateway
  namespace: istio-gateways
spec:
  ports:
  - name: status-port
    port: 15021
    protocol: TCP
    targetPort: 15021
  - name: tls
    port: 15443
    protocol: TCP
    targetPort: 15443
  - name: hbone
    port: 15008
    protocol: TCP
    targetPort: 15008
  - name: https
    port: 16443
    protocol: TCP
    targetPort: 16443
  - name: tcp-istiod
    port: 15012
    protocol: TCP
    targetPort: 15012
  - name: tcp-webhook
    port: 15017
    protocol: TCP
    targetPort: 15017
  selector:
    app: istio-ingressgateway
    istio: eastwestgateway
    topology.istio.io/network: cluster2
  type: LoadBalancer
EOF


### Install Control Plane / Data Plane
kubectl apply --context ${MGMT} -f - <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: IstioLifecycleManager
metadata:
  name: cluster1-installation
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster1
      istioOperatorSpec:
        profile: ambient
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        namespace: istio-system
        values:
          global:
            meshID: mesh1
            multiCluster:
              clusterName: cluster1
            network: cluster1
          ztunnel:
            env:
              ZERO_COPY_DISABLED: true
              MULTICLUSTER_SPIFFE_SERVICE_ACCOUNT: istio-eastwestgateway-service-account
              MULTICLUSTER_SPIFFE_NAMESPACE: istio-gateways
            meshConfig:
              accessLogFile: /dev/stdout
              defaultConfig:
                proxyMetadata:
                  ISTIO_META_DNS_CAPTURE: "true"
                  ISTIO_META_DNS_AUTO_ALLOCATE: "true"
                  DNS_PROXY_ADDR: 0.0.0.0:15053
        meshConfig:
          trustDomain: cluster.local
          accessLogFile: /dev/stdout
          defaultConfig:
            proxyMetadata:
              ISTIO_META_DNS_CAPTURE: "true"
              ISTIO_META_DNS_AUTO_ALLOCATE: "true"
              DNS_PROXY_ADDR: 0.0.0.0:15053
        components:
          ingressGateways:
          - name: istio-ingressgateway
            enabled: false
          pilot:
            k8s:
              env:
                - name: PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES
                  value: "true"
                - name: VERIFY_CERTIFICATE_AT_CLIENT
                  value: "false"
          ingressGateways:
          - name: istio-ingressgateway
            enabled: false
EOF
kubectl apply --context ${MGMT} -f - <<EOF

apiVersion: admin.gloo.solo.io/v2
kind: GatewayLifecycleManager
metadata:
  name: cluster1-ingress
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster1
        activeGateway: false
      istioOperatorSpec:
        profile: empty
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        values:
          gateways:
            istio-ingressgateway:
              customService: true
        meshConfig:
          trustDomain: cluster.local
        components:
          ingressGateways:
            - name: istio-ingressgateway
              namespace: istio-gateways
              enabled: true
              label:
                istio: ingressgateway
---
apiVersion: admin.gloo.solo.io/v2
kind: GatewayLifecycleManager
metadata:
  name: cluster1-eastwest
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster1
        activeGateway: false
      istioOperatorSpec:
        profile: empty
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        values:
          gateways:
            istio-ingressgateway:
              customService: true
        meshConfig:
          trustDomain: cluster.local
        components:
          ingressGateways:
            - name: istio-eastwestgateway
              namespace: istio-gateways
              enabled: true
              label:
                istio: eastwestgateway
                topology.istio.io/network: cluster1
              k8s:
                env:
                  - name: ISTIO_META_ROUTER_MODE
                    value: "sni-dnat"
                  - name: ISTIO_META_REQUESTED_NETWORK_VIEW
                    value: cluster1
EOF

kubectl apply --context ${MGMT} -f - <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: IstioLifecycleManager
metadata:
  name: cluster2-installation
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster2
      istioOperatorSpec:
        profile: ambient
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        namespace: istio-system
        values:
          global:
            meshID: mesh1
            multiCluster:
              clusterName: cluster2
            network: cluster2
          ztunnel:
            env:
              ZERO_COPY_DISABLED: true
              MULTICLUSTER_SPIFFE_SERVICE_ACCOUNT: istio-eastwestgateway-service-account
              MULTICLUSTER_SPIFFE_NAMESPACE: istio-gateways
            meshConfig:
              accessLogFile: /dev/stdout
              defaultConfig:
                proxyMetadata:
                  ISTIO_META_DNS_CAPTURE: "true"
                  ISTIO_META_DNS_AUTO_ALLOCATE: "true"
                  DNS_PROXY_ADDR: 0.0.0.0:15053
        meshConfig:
          trustDomain: cluster.local
          accessLogFile: /dev/stdout
          defaultConfig:
            proxyMetadata:
              ISTIO_META_DNS_CAPTURE: "true"
              ISTIO_META_DNS_AUTO_ALLOCATE: "true"
              DNS_PROXY_ADDR: 0.0.0.0:15053
        components:
          ingressGateways:
          - name: istio-ingressgateway
            enabled: false
          pilot:
            k8s:
              env:
                - name: PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES
                  value: "true"
                - name: VERIFY_CERTIFICATE_AT_CLIENT
                  value: "false"
          ingressGateways:
          - name: istio-ingressgateway
            enabled: false
EOF
kubectl apply --context ${MGMT} -f - <<EOF

apiVersion: admin.gloo.solo.io/v2
kind: GatewayLifecycleManager
metadata:
  name: cluster2-ingress
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster2
        activeGateway: false
      istioOperatorSpec:
        profile: empty
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        values:
          gateways:
            istio-ingressgateway:
              customService: true
        meshConfig:
          trustDomain: cluster.local
        components:
          ingressGateways:
            - name: istio-ingressgateway
              namespace: istio-gateways
              enabled: true
              label:
                istio: ingressgateway
---
apiVersion: admin.gloo.solo.io/v2
kind: GatewayLifecycleManager
metadata:
  name: cluster2-eastwest
  namespace: gloo-mesh
spec:
  installations:
    - clusters:
      - name: cluster2
        activeGateway: false
      istioOperatorSpec:
        profile: empty
        hub: us-docker.pkg.dev/solo-io-ambient/istio
        tag: 1.18-alpha.2aca702fc305248b20a7cd91ba940ce20397dcf0
        values:
          gateways:
            istio-ingressgateway:
              customService: true
        meshConfig:
          trustDomain: cluster.local
        components:
          ingressGateways:
            - name: istio-eastwestgateway
              namespace: istio-gateways
              enabled: true
              label:
                istio: eastwestgateway
                topology.istio.io/network: cluster2
              k8s:
                env:
                  - name: ISTIO_META_ROUTER_MODE
                    value: "sni-dnat"
                  - name: ISTIO_META_REQUESTED_NETWORK_VIEW
                    value: cluster2
EOF

echo "Wait for the GM-IOP"
sleep 15s


../scripts/check.sh $CLUSTER1 istio-system
../scripts/check.sh $CLUSTER1 istio-ingress
../scripts/check.sh $CLUSTER2 istio-system
../scripts/check.sh $CLUSTER2 istio-ingress


export ENDPOINT_HTTP_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].*}'):443
export HOST_GW_CLUSTER1=$(echo ${ENDPOINT_HTTP_GW_CLUSTER1} | cut -d: -f1)
export ENDPOINT_HTTP_GW_CLUSTER2=$(kubectl --context ${CLUSTER2} -n istio-gateways get svc -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTPS_GW_CLUSTER2=$(kubectl --context ${CLUSTER2} -n istio-gateways get svc -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].*}'):443
export HOST_GW_CLUSTER2=$(echo ${ENDPOINT_HTTP_GW_CLUSTER2} | cut -d: -f1)

#### End install Istio ---- ####

kubectl --context ${CLUSTER1} create ns httpbin
kubectl --context ${CLUSTER1} label namespace httpbin istio.io/dataplane-mode=ambient
kubectl apply --context ${CLUSTER1} -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: not-in-mesh
  namespace: httpbin
---
apiVersion: v1
kind: Service
metadata:
  name: not-in-mesh
  namespace: httpbin
  labels:
    app: not-in-mesh
    service: not-in-mesh
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 80
  selector:
    app: not-in-mesh
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: not-in-mesh
  namespace: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: not-in-mesh
      version: v1
  template:
    metadata:
      annotations:
        ambient.istio.io/redirection: disabled
      labels:
        app: not-in-mesh
        version: v1
    spec:
      serviceAccountName: not-in-mesh
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: not-in-mesh
        ports:
        - containerPort: 80
EOF

kubectl apply --context ${CLUSTER1} -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: in-mesh
  namespace: httpbin
---
apiVersion: v1
kind: Service
metadata:
  name: in-mesh
  namespace: httpbin
  labels:
    app: in-mesh
    service: in-mesh
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 80
  selector:
    app: in-mesh
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: in-mesh
  namespace: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: in-mesh
      version: v1
  template:
    metadata:
      labels:
        app: in-mesh
        version: v1
    spec:
      serviceAccountName: in-mesh
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: in-mesh
        ports:
        - containerPort: 80
EOF

### install gateway CRDs

kubectl --context ${CLUSTER1} get crd gateways.gateway.networking.k8s.io &> /dev/null || \
 kubectl --context ${CLUSTER1} apply -f gateway-api.yaml

kubectl --context ${CLUSTER2} get crd gateways.gateway.networking.k8s.io &> /dev/null || \
 kubectl --context ${CLUSTER2} apply -f gateway-api.yaml


#### Install kiali
kubectl apply -f $ISTIO_ROOT_DIR/samples/addons --context $CLUSTER1