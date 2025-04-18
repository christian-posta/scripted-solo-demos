DIR=$(dirname ${BASH_SOURCE})
source ./env.sh
# full API: https://github.com/gogs/docs-api

echo "Using kube context: $CONTEXT"

echo "Setting up GOGS"

kubectl --context $CONTEXT create ns gogs
kubectl --context $CONTEXT create cm custom-gogs -n gogs --from-file resources/gitops/gogs/app.ini
kubectl --context $CONTEXT apply -f resources/gitops/gogs/gogs.yaml
kubectl --context $CONTEXT rollout status -n gogs deploy/gogs

# create user
echo "Creating the user..."

# We will sleep for a sec to let the gogs pod start up correctly before creating the user
sleep 5s

kubectl --context $CONTEXT -n gogs exec -it deploy/gogs -- /bin/sh -c 'gosu git ./gogs admin create-user --name ceposta --password admin123 --email christian@solo.io --admin'

### For now we'll exit the set up until we have more stuff to do
exit 0










URL="http://gogs.gloo-mesh.istiodemos.io"

# create a token
curl -u "ceposta:admin123" -H 'content-type: application/json' -X POST $URL/api/v1/users/ceposta/tokens -d '{"name": "gogs"}'

# get tokens
curl -u "ceposta:admin123" -X GET $URL/api/v1/users/ceposta/tokens 

# save token
TOKEN=$(curl -s -u "ceposta:admin123" -X GET $URL/api/v1/users/ceposta/tokens  | jq .[].sha1 |sed -e 's/"//g')

# create repo for gloo-mesh-config
curl -v -H 'content-type: application/json'  -H "Authorization: token $TOKEN" -X POST $URL/api/v1/admin/users/ceposta/repos -d '{"name": "gloo-mesh-config", "description": "Platform gloo-mesh config", "private": false}'


REPO_FOLDER=$(mktemp -d)
echo "using folder: $REPO_FOLDER"

mkdir -p $REPO_FOLDER/demo-config
cp $DIR/resources/virtual-mesh-acp.yaml $REPO_FOLDER/demo-config
cp $DIR/resources/gmg-routing/ratelimit-server-config.yaml $REPO_FOLDER/demo-config
# TODO::ceposta: Hack until this is fixed: https://github.com/solo-io/gloo-mesh-enterprise/issues/1332
cp $DIR/resources/gmg-routing/virtual-gateway-rate-limit.yaml $REPO_FOLDER/demo-config
cp $DIR/resources/gmg-routing/virtual-gateway.yaml $REPO_FOLDER/demo-config
cp -r $DIR/resources/failover-config/ $REPO_FOLDER/demo-config
cp -r $DIR/resources/acp-config/ $REPO_FOLDER/demo-config

mkdir -p $REPO_FOLDER/bookinfo-config
cp $DIR/resources/bookinfo/resources/enable-ingress-gmg.yaml $REPO_FOLDER/bookinfo-config
cp $DIR/resources/bookinfo/resources/enable-productpage-reviews.yaml $REPO_FOLDER/bookinfo-config
cp $DIR/resources/bookinfo/resources/productpage-virtual-destination.yaml $REPO_FOLDER/bookinfo-config
# TODO::ceposta: Hack until this is fixed: https://github.com/solo-io/gloo-mesh-enterprise/issues/1332
cp $DIR/resources/bookinfo/resources/virtual-gateway.yaml $REPO_FOLDER/bookinfo-config
cp $DIR/resources/bookinfo/resources/traffic-rules/traffic-v1.yaml $REPO_FOLDER/bookinfo-config

if [ "$USING_KIND" == "true" ] ; then
    ln -snf $REPO_FOLDER/ $DIR/resources/gitops/demo-config-repo-kind
else
    ln -snf $REPO_FOLDER/ $DIR/resources/gitops/demo-config-repo
fi


pushd $REPO_FOLDER
git init
git add . 
git commit -m 'initial commit for gloo-mesh-config'
git remote add origin http://ceposta:admin123@gogs.gloo-mesh.istiodemos.io/ceposta/gloo-mesh-config.git
git push -u origin master
popd