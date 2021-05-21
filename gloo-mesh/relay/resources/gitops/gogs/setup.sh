DIR=$(dirname ${BASH_SOURCE})

kubectl create ns gogs

kubectl create cm custom-gogs -n gogs --from-file $DIR/app.ini

kubectl apply -f $DIR/gogs.yaml

kubectl rollout status -n gogs deploy/gogs

# create user
echo "Creating the user..."

kubectl -n gogs exec -it deploy/gogs -- /bin/sh -c 'gosu git ./gogs admin create-user --name ceposta --password admin123 --email christian@solo.io --admin'

kubectl apply -f $DIR/../../resources/gloo/gogs-vs.yaml 

# wait for VS to take effect
sleep 5s

. $DIR/setup-petclinic-repo.sh

