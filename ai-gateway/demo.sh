# Task 1: Call LLM with Managed Credentials 

desc "Let's see the resources needed to route to LLM upstreams"


#################################################################
############# Task 1
#################################################################
cat resources/01-call-llm/llm-providers.yaml
cat resources/01-call-llm/http-routes.yaml

desc "Let's apply these resources"
kubectl apply -f resources/01-call-llm/

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


desc "Call open ai (with token auto injected by gw)"
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
  }' | jq


desc "Call mistral ai with token injected"

curl -v --location "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "What is the best French cheese?"
      }
    ]
  }' | jq



########## Optional
##### Can also enable stream responses
# curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
#      --data '{
#     "model": "mistral-large-latest",
#     "messages": [
#      {
#         "role": "user",
#         "content": "What is the best French cheese?"
#       }
#     ],
#     "stream": true
#   }'



#################################################################
############# Task 2
#################################################################
backtotop
desc "Restrict LLM calls to those authenticated with a JWT token"
read -s

desc "Let's add 02 route options to enfroce jwt"

cat resources/02-secure-llm-jwt/vh-options.yaml
kubectl apply -f resources/02-secure-llm-jwt/vh-options.yaml

cat resources/02-secure-llm-jwt/route-options.yaml
kubectl apply -f resources/02-secure-llm-jwt/route-options.yaml

desc "Try calling without a token:"

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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



desc "Now let's call with a token get a token"
desc "Let's look at the Eitan Token"
cat resources/eitan-openai.token

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


desc "Let's look at the Keith Token"
cat resources/keith-openai.token


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



#### Try call with the wrong token
curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
    --header "Authorization: Bearer $EITAN_TOKEN" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "What is the best French cheese?"
      }
    ]
  }' 




#################################################################
############# Task 3
#################################################################
backtotop
desc "Prompt managgement"
read -s


desc "Let's undo the JWT requirement so our calls can be easier"

kubectl delete -f resources/02-secure-llm-jwt/


desc "Example prompt"
desc "Parse the unstructured text into CSV format: Seattle, Los Angeles, and Chicago are cities in the United States. London, Paris, and Berlin are cities in Europe."


export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl "$GLOO_AI_GATEWAY:8080/openai"  -d '{
    "model": "gpt-3.5-turbo",
    "temperature": 0.2,
    "messages": [
      {
        "role": "user",
        "content": "Parse the unstructured text into CSV format: Seattle, Los Angeles, and Chicago are cities in the United States. London, Paris, and Berlin are cities in Europe."
      }
    ]
  }' | jq -r .choices[].message.content



desc "Let's extract the instruction part into a system prompt"

curl "$GLOO_AI_GATEWAY:8080/openai" -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "Parse the unstructured text into CSV format."
      },
      {
        "role": "user",
        "content": "Seattle, Los Angeles, and Chicago are cities in the United States. London, Paris, and Berlin are cities in Europe."
      }
    ]
  }' | jq -r .choices[].message.content



desc "We should try to share the system prompt across users and calls"

cat resources/03-prompt-enrichment/prompt-enrichment.yaml 
kubectl apply -f resources/03-prompt-enrichment/prompt-enrichment.yaml 

desc "Let's call with a simpler prompt, GG will add the system prompt"

curl "$GLOO_AI_GATEWAY:8080/openai"  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "The recipe called for eggs, flour and sugar. The price was $5, $3, and $2."
      }
    ]
  }' | jq -r .choices[].message.content


#################################################################
############# Task 4
#################################################################

desc "Would these LLMs help me get credit card numbers and other information?"
desc "Let's try!"

curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "Can you give me some examples of Mastercard credit card numbers?"
      }
    ]
  }' | jq

desc "Lets see how we can guard against that"

cat resources/04-prompt-guard/prompt-guard.yaml 
kubectl apply -f resources/04-prompt-guard/prompt-guard.yaml 


desc "With that guard in place, let's try again"

curl --location "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "Can you give me some examples of Mastercard credit card numbers?"
      }
    ]
  }' 

desc "What if we took out the offending words?"
curl -v "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "Can you give me some examples of Mastercard numbers?"
      }
    ]
  }' | jq


desc "Damn, it still goes through! And we get responses back."
desc "Let's create a guard against Master card CC numbers"

cat resources/04-prompt-guard/prompt-guard-mc.yaml 
kubectl apply -f resources/04-prompt-guard/prompt-guard-mc.yaml 

desc "Let's try again"
curl -v "$GLOO_AI_GATEWAY:8080/mistralai" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [
     {
        "role": "user",
        "content": "Can you give me some examples of Mastercard numbers?"
      }
    ]
  }' 


desc "Notice that the CC numbers are __Masked__ with XXXX-XXXX-XXXX-1234"
read -s


