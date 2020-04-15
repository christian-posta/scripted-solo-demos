source ~/bin/ddns-token

kubectl apply -f resources/petstore.yaml
kubectl apply -f resources/petstore-vs.yaml
kubectl apply -f resources/glooui-vs.yaml
kubectl apply -f resources/devportal-vs.yaml

echo "Updating DDNS"
SVC_IP=$(kubectl get svc -l gloo=gateway-proxy -n gloo-system -o "jsonpath={.items[].status.loadBalancer.ingress[0].ip}")

# apis
curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=apis.myddns.me&myip=$SVC_IP"   

# gloo
curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=gloo.myddns.me&myip=$SVC_IP"   

# glooui
curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=glooui.myddns.me&myip=$SVC_IP"   

# petstore
curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=petstore.myddns.me&myip=$SVC_IP"   