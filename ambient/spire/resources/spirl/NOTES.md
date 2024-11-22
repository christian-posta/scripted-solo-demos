Install istio with revisions

```bash
istioctl install -f istio-install.yaml -y

kubectl create ns istio-ingress
istioctl install -f istio-gateway.yaml -y
```

Install bookinfo

```bash
kubectl label namespace default istio-injection=enabled --overwrite
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml -n default
```

Get the GW IP

```bash
GW_IP=$(kubectl get service istio-ingressgateway -n istio-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl $GW_IP/productpage
```

Install SPIRL:
NOTE that the trust domain must match what's in the istio installation

```bash
spirlctl cluster add gmv2-istio-demo --trust-domain example.org --platform istio --kube-context istio-demo --yes
```

Patch Injector for SPIRL

```bash
istioctl install -f istio-install-spirl.yaml -y


for deployment in $(kubectl get deployments -n default -o jsonpath='{.items[*].metadata.name}'); do
  kubectl patch deployment "$deployment" -n default --patch '{"spec": {"template": {"metadata": {"annotations": {"inject.istio.io/templates": "sidecar,spirl"}}}}}'
done
```

All workloads should get certs from SPIRL now. 

Let's verify:

```bash
NAMESPACE=default
POD=$(kubectl get pods -n $NAMESPACE | grep productpage | awk '{print $1}')


istioctl proxy-config secret $POD -n $NAMESPACE -o json | jq -r '.dynamicActiveSecrets[] | select(.name == "ROOTCA") | .secret.validationContext.customValidatorConfig.typedConfig.trustDomains[0].trustBundle.inlineBytes' | base64 -d | step certificate inspect -

```

May need to use this:





Adding in support for the gateway:

```bash
istioctl install -f istio-gateway-spirl.yaml -y

NAMESPACE=istio-ingress
POD=$(kubectl get pods -n $NAMESPACE | grep ingress | awk '{print $1}')


```


Let's patch the injector config map

kubectl get cm istio-sidecar-injector-1-23 -n istio-system -o jsonpath='{.data.config}' > injector-config.yaml

yq eval '.templates.gateway' injector-config.yaml > gateway-base.yaml

manually edit the gateway-base.yaml

NEW_TEMPLATE=$(cat gateway-base.yaml | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
NEW_TEMPLATE=$(cat gateway-base.yaml)

kubectl patch cm istio-sidecar-injector-1-23 -n istio-system --type merge --patch "$(cat <<EOF
{
  "data": {
    "templates.gateway-spirl": "$NEW_TEMPLATE"
  }
}
EOF
)"












Call from product page to reviews:

kubectl exec -it $POD -n default -- python3 -c "import http.client; conn = http.client.HTTPConnection('reviews', 9080); conn.request('GET', '/reviews/1'); response = conn.getresponse(); print('Status:', response.status); print('Response:', response.read().decode()); conn.close()"


kubectl exec -it $POD -n default -c istio-proxy -- openssl s_client -connect reviews:9080 -showcerts






