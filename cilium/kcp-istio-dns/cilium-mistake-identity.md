

# Set up the cluster scenario

../scripts/deploy-multi-without-cni.sh 1 cluster1
kubectl config use-context cluster1

helm repo update
helm upgrade --install cilium cilium/cilium --version 1.14.0 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set k8sServiceHost=kind1-control-plane \
  --set k8sServicePort=6443 \
  --set socketLB.enabled=false \
  --set externalIPs.enabled=true \
  --set bpf.masquerade=false \
  --set image.pullPolicy=IfNotPresent \
  --set l7Proxy=false \
  --set encryption.enabled=true \
  --set encryption.type=wireguard


cat <<EOF | istioctl install -y -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    defaultConfig:
      proxyMetadata:
        # Enable basic DNS proxying
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation, optional
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
EOF


kubectl label namespace default istio-injection=enabled
kubectl apply -f ./samples/ -n default


```
solo@ceposta-test-lab-vms-3:~/scripted-demos/cilium/kcp-istio-dns$ k get po -o wide
NAME                        READY   STATUS    RESTARTS   AGE    IP             NODE            NOMINATED NODE   READINESS GATES
httpbin-85d76b4bb6-hx5b2    2/2     Running   0          24d    10.101.2.202   kind1-worker    <none>           <none>
sleep-v1-fc8f44fbc-l8pht    2/2     Running   0          7d1h   10.101.2.38    kind1-worker    <none>           <none>
sleep-v2-568c9b7786-m9m5w   2/2     Running   0          24d    10.101.1.160   kind1-worker2   <none>           <none>
```


```
solo@ceposta-test-lab-vms-3:~/scripted-demos/cilium/kcp-istio-dns$ k get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
httpbin      ClusterIP   10.1.190.140   <none>        8000/TCP   24d
kubernetes   ClusterIP   10.1.0.1       <none>        443/TCP    24d
sleep-v1     ClusterIP   10.1.58.18     <none>        80/TCP     24d
sleep-v2     ClusterIP   10.1.152.206   <none>        80/TCP     24d
```





### From sleep container
curl -v httpbin:8000/headers



termshark -i any



# Set up the non KPR scenario (without ISTIO)

../scripts/deploy-multi-without-cni-no-kp.sh 1 cluster1
kubectl config use-context cluster1

helm upgrade --install cilium cilium/cilium --version 1.13.2 \
  --namespace kube-system \
  --set ipam.mode=kubernetes  \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=kind1-control-plane \
  --set k8sServicePort=6443

kubectl apply -f ./samples/ -n default  


```
solo@ceposta-test-lab-vms-3:~/scripted-demos/cilium/kcp-istio-dns$ k get po -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE            NOMINATED NODE   READINESS GATES
httpbin-85d76b4bb6-qfmz4    1/1     Running   0          21s   10.101.2.90    kind1-worker    <none>           <none>
sleep-v1-fc8f44fbc-42zp9    1/1     Running   0          21s   10.101.3.10    kind1-worker3   <none>           <none>
sleep-v2-568c9b7786-td9j9   1/1     Running   0          21s   10.101.2.193   kind1-worker    <none>           <none>
```


```
solo@ceposta-test-lab-vms-3:~/scripted-demos/cilium/kcp-istio-dns$ k get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
httpbin      ClusterIP   10.1.173.125   <none>        8000/TCP   111s
kubernetes   ClusterIP   10.1.0.1       <none>        443/TCP    5m24s
sleep-v1     ClusterIP   10.1.239.11    <none>        80/TCP     111s
sleep-v2     ClusterIP   10.1.202.80    <none>        80/TCP     111s
```


### From sleep container
curl -v httpbin:8000/headers





# Set up the non KPR scenario with Istio 


../scripts/deploy-multi-without-cni-no-kp.sh 1 cluster1
kubectl config use-context cluster1

helm upgrade --install cilium cilium/cilium --version 1.13.2 \
  --namespace kube-system \
  --set ipam.mode=kubernetes  \
  --set kubeProxyReplacement=strict \
  --set socketLB.hostNamespaceOnly=true \
  --set k8sServiceHost=kind1-control-plane \
  --set k8sServicePort=6443


>> Put Istio here

kubectl apply -f ./samples/ -n default  

