source ~/bin/ddns-token

SVC_IP=$(kubectl  get svc -n istio-system | grep ingressgateway | awk ' { print $ 4 }')

# petstore
curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=petstore.myddns.me&myip=$SVC_IP"   

curl -H "User-Agent: Company NameOfProgram/OSVersion-ReleaseVersion maintainer-contact@example.com" -H "Authorization: Basic $DDNSAUTH"  "https://dynupdate.no-ip.com/nic/update?hostname=apis.myddns.me&myip=$SVC_IP"   