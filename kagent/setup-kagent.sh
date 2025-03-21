source env.sh

source ~/bin/ai-keys


# helm search repo oci://ghcr.io/kagent-dev/kagent/helm/kagent --versions

helm upgrade --install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
    --namespace kagent \
    --create-namespace \
    --version $KAGENT_VERSION \
    --set openai.apiKey=$OPENAI_API_KEY

