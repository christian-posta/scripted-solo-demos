DIR=$(dirname ${BASH_SOURCE})

# full API: https://github.com/gogs/docs-api

URL="http://gogs.mesh.ceposta.solo.io"

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


cp -r $DIR/resources/failover-config $REPO_FOLDER/

ln -snf $REPO_FOLDER/ $DIR/resources/gitops/demo-config-repo

pushd $REPO_FOLDER
git init
git add . 
git commit -m 'initial commit for gloo-mesh-config'
git remote add origin $URL/ceposta/gloo-mesh-config.git
git push -u origin master
popd