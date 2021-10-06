
source ./env.sh
. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Press <Enter> to verify data plane"
read -s

run "kubectl --context $CLUSTER_1 exec -it deploy/east-west-gateway -n istio-system -- pilot-agent request GET server_info --log_as_json|jq {version}"

desc "Press <Enter> to verify control plane"
read -s

POD=$(kubectl --context $CLUSTER_1 get po -n istio-system | grep istiod | awk '{print $1}')
rm -f /tmp/pilot-discovery
run "kubectl --context $CLUSTER_1 cp -c discovery istio-system/$POD:/usr/local/bin/pilot-discovery /tmp/pilot-discovery && chmod +x /tmp/pilot-discovery"

desc "We should see (boring crypto) as the ssl proivder"
run "goversion -crypto /tmp/pilot-discovery"
