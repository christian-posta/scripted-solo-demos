pod=$(kubectl get po | grep $1 | awk '{ print $1}')

kubectl debug -it ${pod} --image=nicolaka/netshoot --image-pull-policy=Always -- bash


