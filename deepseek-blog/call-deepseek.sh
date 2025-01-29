
# consider updating to newer Gateway CRDs
export GLOO_AI_GATEWAY=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


# Helper function to build the curl command
_build_curl_command() {
    local token="${1:-}"
    local model="${2:-deepseek-chat}"
    local path="${3:-deepseek}"
    local user_prompt="${4:-What is 2 + 2?}"


    local headers=("-H" "\"content-type:application/json\"")
    if [[ -n "$token" ]]; then
        headers+=("-H" "\"Authorization: Bearer $token\"")
    fi

    echo "curl \"$GLOO_AI_GATEWAY:8080/$path\" ${headers[@]} -d '{
      \"model\": \"$model\",
      \"max_tokens\": 4096,
      \"stream\": false,
      \"messages\": [
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
  if echo "$response" | jq . >/dev/null 2>&1; then
      echo "$response" | jq .
  else
      echo "$response"
  fi
}

