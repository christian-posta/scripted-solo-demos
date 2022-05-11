
DIR=$(dirname ${BASH_SOURCE})
source ./env-workshop.sh
# full API: https://github.com/gogs/docs-api

echo "Setting up GOGS"

kubectl --context $CLUSTER1 create ns gogs
kubectl --context $CLUSTER1 create cm custom-gogs -n gogs --from-file ./gitops/gogs/app.ini
kubectl --context $CLUSTER1 apply -f ./gitops/gogs/gogs.yaml
kubectl --context $CLUSTER1 rollout status -n gogs deploy/gogs


echo "wait for Gogs to settle in... press ENTER to continue"
read -s

# create user
echo "Creating the user..."

kubectl --context $CLUSTER1 -n gogs exec -it deploy/gogs -- /bin/sh -c 'gosu git ./gogs admin create-user --name ceposta --password admin123 --email christian@solo.io --admin'


kubectl --context $CLUSTER1 port-forward -n gogs deploy/gogs 3000 &> /dev/null &
PF_PID="$!"
echo "PID of port-forward: $PF_PID"



function cleanup {
  kill -9 $PF_PID
}

trap cleanup EXIT

echo "Sleeping 5s for port-forward"
sleep 5s


URL="http://localhost:3000"

# create a token
curl -u "ceposta:admin123" -H 'content-type: application/json' -X POST $URL/api/v1/users/ceposta/tokens -d '{"name": "gogs"}'

# get tokens
curl -u "ceposta:admin123" -X GET $URL/api/v1/users/ceposta/tokens 

# save token
TOKEN=$(curl -s -u "ceposta:admin123" -X GET $URL/api/v1/users/ceposta/tokens  | jq .[].sha1 |sed -e 's/"//g')

# create repo for gloo-mesh-config
curl -v -H 'content-type: application/json'  -H "Authorization: token $TOKEN" -X POST $URL/api/v1/admin/users/ceposta/repos -d '{"name": "routing-config", "description": "Routing configuration for App Team FOO", "private": false}'


echo "Creating REPO... ENTER to cont"
read -s


REPO_FOLDER=$(mktemp -d)
echo "using folder: $REPO_FOLDER"

BOOKINFO_FOLDER="$REPO_FOLDER/bookinfo-workspace"
GATEWAYS_FOLDER="$REPO_FOLDER/gateways-workspace"

mkdir -p $BOOKINFO_FOLDER
mkdir -p $GATEWAYS_FOLDER

cp $DIR/policies/clean-workspacesettings.yaml $BOOKINFO_FOLDER/workspacesettings.yaml
cp $DIR/policies/clean-virtualgateway.yaml $GATEWAYS_FOLDER/virtualgateway.yaml
cp $DIR/policies/clean-faultinjection-policy.yaml $BOOKINFO_FOLDER/faultinjection-policy.yaml
cp $DIR/policies/clean-faultinjection-routetable-clean.yaml $BOOKINFO_FOLDER/ratings-routetable.yaml
cp $DIR/policies/clean-virtualdestination.yaml $BOOKINFO_FOLDER/virtualdestination.yaml
cp $DIR/policies/clean-failoverpolicy-outlier.yaml $BOOKINFO_FOLDER/outlier-policy.yaml
cp $DIR/policies/clean-failoverpolicy.yaml $BOOKINFO_FOLDER/failover-policy.yaml
cp $DIR/policies/clean-routetable.yaml $BOOKINFO_FOLDER/routetable.yaml
cp $DIR/policies/clean-ratelimit-client-server.yaml $BOOKINFO_FOLDER/ratelimit-client-server.yaml
cp $DIR/policies/clean-ratelimit-policy.yaml $BOOKINFO_FOLDER/ratelimit-policy.yaml
cp $DIR/policies/clean-ratelimit-serversettings.yaml $BOOKINFO_FOLDER/ratelimit-serversettings.yaml


if [ "$USING_KIND" == "true" ] ; then
    ln -snf $REPO_FOLDER/ $DIR/gitops/demo-config-repo-kind
else
    ln -snf $REPO_FOLDER/ $DIR/resources/gitops/demo-config-repo
fi


pushd $REPO_FOLDER
git init
git add . 
git commit -m 'initial commit for gloo-mesh-config'
git remote add origin http://ceposta:admin123@localhost:3000/ceposta/routing-config.git
git push -u origin master
popd