# consider updating to newer Gateway CRDs
export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


PORT=8080
export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):$PORT


if [[ -z "$GLOO_AI_GATEWAY" || "$GLOO_AI_GATEWAY" == ":$PORT" ]]; then
  echo "Could not determine GLOO_AI_GATEWAY IP automatically."
  read -p "Please enter the external IP or hostname for ai-gateway: " GLOO_AI_GATEWAY
  export GLOO_AI_GATEWAY
fi



# Helper function to build the curl command
_build_curl_command() {
    local token="${1:-}"
    local model="${2:-gpt-3.5-turbo}"
    local path="${3:-openai}"
    local system_prompt="${4:-You grew up in Phoenix, AZ and are now a travel expert.}"
    local user_prompt="${5:-Tell me about Sedona, AZ in 20 words or fewer.}"
    local x_action="${6:-}"

    local headers=("-H" "\"content-type:application/json\"")
    if [[ -n "$token" ]]; then
        headers+=("-H" "\"Authorization: Bearer $token\"")
    fi

    if [[ -n "$x_action" ]]; then
        headers+=("-H" "\"x-action: $x_action\"")
    fi

    echo "curl -v \"$GLOO_AI_GATEWAY/$path\" ${headers[@]} -d '{
      \"model\": \"$model\",
      \"max_tokens\": 4096,
      \"top_p\": 1,
      \"n\": 1,
      \"stream\": false,
      \"frequency_penalty\": 0.0,  
      \"messages\": [
        {
          \"role\": \"system\",
          \"content\": \"$system_prompt\"
        },
        {
          \"role\": \"user\",
          \"content\": \"$user_prompt\"
        }
      ]
    }'"
}

# Function to print the curl command
print_gateway_command() {
    _build_curl_command "$@"
}

# Function to execute the curl command
call_gateway() {
  _build_curl_command "$@"
  response=$(eval "$(_build_curl_command "$@")")
  
  # Capture both stdout and stderr from jq
  if jq_output=$(printf '%s' "$response" | jq . 2>&1); then
    if [[ $jq_output =~ "parse error" ]]; then
      printf '%s' "$response"  # Print raw response if jq had parse error
    else
      printf '%s' "$jq_output"  # Print formatted JSON
    fi
  else
    printf '%s' "$response"  # Print raw response if jq failed
  fi
}

