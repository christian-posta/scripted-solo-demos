
NUMBER=${1:-1}

../scripts/deploy-multi-without-cni-no-kp.sh $NUMBER "cluster$NUMBER"
kubectl config use-context "cluster$NUMBER"
