DIR=$(dirname ${BASH_SOURCE})
source env.sh

./setup-gogs.sh
./setup-argocd.sh
