CLUSTER=$1


######
# Update Istio's DNS
#####
kubectl --context $CLUSTER apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: istio-system
  labels:
    app: istiocoredns
    release: istio
data:
  Corefile: |
    cluster-2 {
             grpc . 127.0.0.1:8053
          } 	
    cluster-1 {
             grpc . 127.0.0.1:8053
          } 
    .:53 {
          errors
          health 
          grpc global 127.0.0.1:8053
          forward . /etc/resolv.conf {
            except global
          }           
          prometheus :9153
          cache 30
          reload
        }
EOF

kubectl delete pod -n istio-system -l app=istiocoredns --context $CLUSTER


######
# Update kube-dns subs
#####


ISTIO_COREDNS=$(kubectl get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})

kubectl --context $CLUSTER apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {
      "cluster-2": ["$ISTIO_COREDNS"],
      "cluster-1": ["$ISTIO_COREDNS"],
      "global": ["$ISTIO_COREDNS"]
    }
EOF

kubectl delete pod -n kube-system -l k8s-app=kube-dns  --context $CLUSTER