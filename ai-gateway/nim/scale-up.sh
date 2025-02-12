source ./env.sh

gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool default-pool \
    --num-nodes 1 

gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool gpu-pool \
    --num-nodes 1     