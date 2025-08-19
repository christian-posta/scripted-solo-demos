echo "Make sure to set the env variables! ~/bin/cognito-env.sh"

aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id $COGNITO_CLIENT_ID \
  --auth-parameters USERNAME=$COGNITO_USERNAME,PASSWORD=$COGNITO_PASSWORD,SECRET_HASH=$SECRET_HASH \
  --region $AWS_REGION