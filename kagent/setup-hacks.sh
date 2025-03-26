
source env.sh

# need to do this until kagent-v0.1.9 is released
kind load docker-image --name kind1 ghcr.io/kagent-dev/kagent/app:v0.1.8-dirty 

kubectl patch deployment kagent -n kagent --type=strategic --patch '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "image": "ghcr.io/kagent-dev/kagent/app:v0.1.8-dirty"
          }
        ]
      }
    }
  }
}'