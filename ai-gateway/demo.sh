## Task 1

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


# call open ai (with token auto injected by gw)
curl "$GLOO_AI_GATEWAY:8080/openai"  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
      },
      {
        "role": "user",
        "content": "Compose a poem that explains the concept of recursion in programming."
      }
    ]
  }' | jq


# call mistral ai with token injected

curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "What is the best French cheese?"
      }
    ]
  }' | jq



# Task 2



curl -v "$GLOO_AI_GATEWAY:8080/openai"  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
      },
      {
        "role": "user",
        "content": "Compose a poem that explains the concept of recursion in programming."
      }
    ]
  }'




export EITAN_TOKEN=$(cat resources/tokens/eitan-openai.token)

curl "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
      },
      {
        "role": "user",
        "content": "Compose a poem that explains the concept of recursion in programming."
      }
    ]
  }'





# Bob works in the "ops" team and we're going to give him access to the Mistral AI API (specifically the mistral-large-latest model)
export KEITH_TOKEN=$(cat resources/tokens/keith-mistral.token)

curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
    --header "Authorization: Bearer $KEITH_TOKEN" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "What is the best French cheese?"
      }
    ]
  }' 