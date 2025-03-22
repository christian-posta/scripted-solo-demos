DIR=$(dirname ${BASH_SOURCE})
source env.sh

# Add a parameter for action (apply or delete)
ACTION=${1:-apply}  # Default to 'apply' if no argument is provided

# Check if the action is 'delete'
if [ "$ACTION" == "delete" ]; then
    # Delete the namespaces, which will also delete all resources within them
    kubectl --context ${CONTEXT} delete ns bookinfo-frontends
    kubectl --context ${CONTEXT} delete ns bookinfo-backends
else
    # Create namespaces
    kubectl --context ${CONTEXT} create ns bookinfo-frontends
    kubectl --context ${CONTEXT} create ns bookinfo-backends

    # Deploy the frontend bookinfo service in the bookinfo-frontends namespace
    kubectl --context ${CONTEXT} -n bookinfo-frontends apply -f resources/bookinfo/productpage.yaml
    kubectl --context ${CONTEXT} -n bookinfo-frontends set env deploy/productpage-v1 DETAILS_HOSTNAME=details.bookinfo-backends.svc.cluster.local
    kubectl --context ${CONTEXT} -n bookinfo-frontends set env deploy/productpage-v1 REVIEWS_HOSTNAME=reviews.bookinfo-backends.svc.cluster.local

    # Deploy the backend bookinfo services in the bookinfo-backends namespace
    kubectl --context ${CONTEXT} -n bookinfo-backends apply -f resources/bookinfo/details.yaml
    kubectl --context ${CONTEXT} -n bookinfo-backends apply -f resources/bookinfo/ratings.yaml
    
    # Apply reviews but exclude v2 and v3 versions
    kubectl --context ${CONTEXT} -n bookinfo-backends apply -f resources/bookinfo/reviews.yaml

    kubectl --context ${CONTEXT} -n bookinfo-frontends apply -f resources/bookinfo/bookinfo-gateway.yaml 

    ./add-ns-to-mesh.sh "bookinfo-frontends bookinfo-backends"

    # set up load generator
    kubectl --context ${CONTEXT} -n default apply -f load/deployment.yaml 
fi
