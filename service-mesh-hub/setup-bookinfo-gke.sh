. ./env.sh

## Install Bookinfo on cluster 1
kubectl label --context $CLUSTER_1 namespace default istio-injection=enabled
kubectl apply --context $CLUSTER_1 -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl apply --context $CLUSTER_1 -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'




## Install Bookinfo on cluster 2
kubectl label namespace default istio-injection=enabled --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version in (v3)' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'service=reviews' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=reviews' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app=ratings' --context $CLUSTER_2
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account=ratings' --context $CLUSTER_2