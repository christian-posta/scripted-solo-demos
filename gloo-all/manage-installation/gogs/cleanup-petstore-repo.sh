DIR=$(dirname ${BASH_SOURCE})

URL="http://gloo-gogs.demo.ceposta.solo.io"

# full API https://github.com/gogs/docs-api

# save token
TOKEN=$(curl -s -u "ceposta:admin123" -X GET $URL/api/v1/users/ceposta/tokens  | jq .[].sha1 |sed -e 's/"//g')

# delete petclinic
curl -v -H "Authorization: token $TOKEN" -X DELETE $URL/api/v1/repos/ceposta/petstore 

# create repo for petclinic
#curl -v -H 'content-type: application/json'  -H "Authorization: token $TOKEN" -X POST $URL/api/v1/admin/users/ceposta/repos -d '{"name": "petclinic", "description": "Petclinic app", "private": false}'
