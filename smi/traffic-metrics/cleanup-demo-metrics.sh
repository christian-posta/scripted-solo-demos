kubectl delete -f smi-metrics-adapter.yaml
curl -sL https://run.linkerd.io/emojivoto.yml | kubectl delete -f -
linkerd install --ignore-cluster | kubectl delete -f -
