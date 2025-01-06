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
curl "$GLOO_AI_GATEWAY:8080/openai" -H "Content-Type: application/json" -H "Authorization: Bearer $EITAN_TOKEN" -d '{
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
back
desc "Would these LLMs help me get credit card numbers and other information?"
desc "Let's try!"
read -s

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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


#################################################################
############# Task 5
#################################################################
back
desc "How can we protect cost, usage, and rate limit based on tokens?"
read -s

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

desc "Let's put back our JWT authentication"

cat resources/05-ratelimit-token-usage/vh-options.yaml
kubectl apply -f resources/05-ratelimit-token-usage/vh-options.yaml


desc "Let's create a token rate limit (70 per hour) based on user id"

cat resources/05-ratelimit-token-usage/ratelimit-user.yaml
kubectl apply -f resources/05-ratelimit-token-usage/ratelimit-user.yaml

desc "Let's add this token rate limit specifically to the openai route"
cat resources/05-ratelimit-token-usage/openai-route-ratelimit.yaml
kubectl apply -f resources/05-ratelimit-token-usage/openai-route-ratelimit.yaml


desc "Let's use Eitan's token"

export EITAN_TOKEN=$(cat resources/tokens/eitan-openai.token)
curl -v "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" -d '{
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

desc "This first request goes through, but subsequent will fail"
curl -v "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" -d '{
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


#################################################################
############# Task 6
#################################################################

backtotop
desc "Let's see about model failover"
read -s

kubectl get deploy model-failover -n gloo-system

desc "Let's take a look at the quick reconfiguration to point to a model-provider service"
desc "Which will help us simulate bad behaviors"

cat resources/06-model-failover/llm-providers.yaml
kubectl apply -f resources/06-model-failover/llm-providers.yaml

desc "Let's describe the failover behavior"
cat resources/06-model-failover/route-options.yaml
kubectl apply -f resources/06-model-failover/route-options.yaml


export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -v "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" -d '{
    "model": "gpt-4o",
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


desc "We should see the default configured response from the model-failover, but we should see"
desc "That the gateway retried with a different model"

kubectl logs deploy/model-failover -n gloo-system

#################################################################
############# Task 7
#################################################################
backtotop
desc "Lets try RAG"
read -s

desc "First, lets reset the model failover"
kubectl apply -f resources/07-rag/llm-providers.yaml

desc "Try running basic prompt"

export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -v "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" \
     --data '{
    "model": "gpt-4o",
    "messages": [
     {
        "role": "user",
        "content": "How many varieties of cheeses are in France?"
      }
    ]
  }'


desc "This is verbose! Let's use RAG to fine tune it"

desc "Lets see the vector DB"
kubectl get po -n default

desc "Let's apply the RAG route"
cat resources/07-rag/route-options.yaml
kubectl apply -f resources/07-rag/route-options.yaml


desc "Using RAG, we can fine tune the response. let's try again:"


curl -v "$GLOO_AI_GATEWAY:8080/openai" --header "Authorization: Bearer $EITAN_TOKEN" \
     --data '{
    "model": "gpt-4o",
    "messages": [
     {
        "role": "user",
        "content": "How many varieties of cheeses are in France?"
      }
    ]
  }'

desc "This time the response is very specific!  "