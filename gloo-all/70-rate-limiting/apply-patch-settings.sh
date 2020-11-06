
kubectl patch -n gloo-system settings default --type merge --patch "$(cat $1)"