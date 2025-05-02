source env.sh

source ~/bin/ai-keys


# helm search repo oci://ghcr.io/kagent-dev/kagent/helm/kagent --versions

helm install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
    --namespace kagent \
    --create-namespace \
    --version $KAGENT_VERSION

helm upgrade --install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
    --namespace kagent \
    --create-namespace \
    --version $KAGENT_VERSION \
    --set providers.default=openAI \
    --set providers.openAI.apiKey=$OPENAI_API_KEY

