source ../../env.sh

echo "Installing vault into into $CLUSTER_1 and $CLUSTER_2"
echo "Enter to continue"
read -s


for cluster in ${CLUSTER_1} ${CLUSTER_2}; do

  # For more info on vault in kubernetes, please see: https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager

  # install vault in dev mode
  helm install -n vault  vault hashicorp/vault --set "injector.enabled=false" --set "server.dev.enabled=true" --kube-context="${cluster}" --create-namespace

  # Wait for vault to come up, can't use kubectl rollout because it's a stateful set without rolling deployment
  kubectl --context="${cluster}" wait --for=condition=Ready -n vault pod/vault-0

  #sleep anyway
  echo "Sleeping 5s..."
  sleep 5s

  # Enable vault kubernetes Auth
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault auth enable kubernetes'

  # Set the kubernetes Auth config for vault to the mounted token
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'

  # Bind the istiod service account to the pki policy below
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/role/gen-int-ca-istio \
    bound_service_account_names=istiod-service-account \
    bound_service_account_namespaces=istio-system \
    policies=gen-int-ca-istio \
    ttl=2400h'

  # Initialize vault PKI
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable pki'

  # set the vault CA to our pem_bundle
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c "vault write -format=json pki/config/ca pem_bundle=\"$(cat root-key.pem root-cert.pem)\""

  # Initialize vault intermediate path
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable -path pki_int pki'

  # Set the policy for intermediate cert path
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault policy write gen-int-ca-istio - <<EOF
path "pki_int/*" {
capabilities = ["create", "read", "update", "delete", "list"]
}
path "pki/cert/ca" {
capabilities = ["read"]
}
path "pki/root/sign-intermediate" {
capabilities = ["create", "read", "update", "list"]
}
EOF'

done

echo "Updating the virtualmesh to use vault"
echo "Enter to continue"
read -s
kubectl apply -f ./virtual-mesh-vault.yaml
pushd ../../scripts
. ./check-virtualmesh.sh
popd

echo "Updating the clusterrolebinding"
echo "Enter to continue"
read -s


export GLOO_MESH_VERSION="1.1.3"

helm upgrade enterprise-agent --kube-context $CLUSTER_1 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz --set istiodSidecar.createRoleBinding=true

helm upgrade enterprise-agent --kube-context $CLUSTER_2 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz --set istiodSidecar.createRoleBinding=true



echo "Patching cluster 1 istiod agent"
echo "Enter to continue"
read -s

kubectl --context $CLUSTER_1 patch -n istio-system deploy/istiod --patch '{
	"spec": {
			"template": {
				"spec": {
						"initContainers": [
							{
									"args": [
										"init-container"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent-init"
							}
						],
						"containers": [
							{
									"args": [
										"sidecar"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent"
							}
						],
						"volumes": [
							{
									"name": "cacerts",
									"secret": null,
									"emptyDir": {
										"medium": "Memory"
									}
							}
						]
				}
			}
	}
}'

echo "Patching cluster 2 istiod agent"
echo "Enter to continue"
read -s

kubectl --context $CLUSTER_2 patch -n istio-system deploy/istiod --patch '{
	"spec": {
			"template": {
				"spec": {
						"initContainers": [
							{
									"args": [
										"init-container"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent-init"
							}
						],
						"containers": [
							{
									"args": [
										"sidecar"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent"
							}
						],
						"volumes": [
							{
									"name": "cacerts",
									"secret": null,
									"emptyDir": {
										"medium": "Memory"
									}
							}
						]
				}
			}
	}
}'

echo "Verify root certs"
echo "Enter to continue"
read -s

for cluster in ${CLUSTER_1} ${CLUSTER_2}; do
  kubectl --context ${cluster} get cm -n istioinaction istio-ca-root-cert -o jsonpath="{.data   ['root-cert\.pem']}" | step certificate inspect -
done
