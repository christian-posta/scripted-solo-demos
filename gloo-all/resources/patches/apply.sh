DIR=$(dirname ${BASH_SOURCE})


# Patch access log
kubectl patch -n gloo-system gateway gateway-proxy --type merge --patch "$(cat $DIR/gateway-access-log-patch.yaml)"
kubectl patch -n gloo-system gateway gateway-proxy-ssl --type merge --patch "$(cat $DIR/gateway-access-log-patch.yaml)"

# patch useremoteaddress
kubectl patch -n gloo-system gateway gateway-proxy --type merge --patch "$(cat $DIR/gateway-remote-address-patch.yaml)"
kubectl patch -n gloo-system gateway gateway-proxy-ssl --type merge --patch "$(cat $DIR/gateway-remote-address-patch.yaml)"
