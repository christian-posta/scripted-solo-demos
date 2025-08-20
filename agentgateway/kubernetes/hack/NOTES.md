## install ambient mesh
curl -sSL https://get.ambientmesh.io | bash -

## Install kgateway
kubectl apply -f kubernetes/hack/crds.yaml


>>> Install private kgateway with agent gateway support

kubectl apply -f kubernetes/hack/waypoint.yaml 

## Enroll into ambient

deploy sample apps:

kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/sleep/sleep.yaml

### enroll the namespace in ambient
kubectl label namespace default istio.io/dataplane-mode=ambient

### enroll the httpbin service into the waypoint:
kubectl label svc httpbin istio.io/use-waypoint=waypoint
istioctl zc s


### try traffic:
kubectl exec deploy/sleep -- curl -s http://httpbin:8000/get

Check here:
https://kgateway.dev/docs/integrations/istio/ambient/waypoint/


### try mcp endpoint:
kubectl apply -f kubernetes/mcp.yaml
kubectl label svc mcp-website-fetcher istio.io/use-waypoint=waypoint
istioctl zc s

kubectl apply -f kubernetes/hack/httproute.yaml

curl -X POST http://mcp-website-fetcher.default/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "protocolVersion": "2025-03-26",
          "capabilities": {},
          "clientInfo": {
            "name": "your-client-name",
            "version": "1.0.0"
          }
        }
      }'



data: {"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-03-26","capabilities":{"prompts":{},"resources":{},"tools":{}},"serverInfo":{"name":"rmcp","version":"0.3.1"},"instructions":"This server is a gateway to a set of mcp servers. It is responsible for routing requests to the correct server and aggregating the results."}}