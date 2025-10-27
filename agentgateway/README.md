# Agentgateway Demo

* Calling multiple backend LLMs with unified (OpenAI) API
* Egress controls with API key injection
* Securing with SSO
* Rate limit
* Metrics collection with grafana dashboards
* Tracing
* Guardrails
* Failover
* Integration with OpenFGA / OPA

Demo through CLI and UI. 

The models we use in this demo:

* OpenAI: gpt-4o 
* Anthropic: claude-3-5-sonnet-20241022
* Gemini: gemini-2.5-flash-lite
* Bedrock: global.anthropic.claude-sonnet-4-20250514-v1:0

## Running agentgateway

The configuration (./config/agentgateway_config.yaml) uses ENV variables for some values (ie, ratelimit server, ). These will need to be set ahead of time. 

The env variables to set are in the `./config/example.env` file. Copy that to a `.env` file and you can run with docker compose.

There are profiles you can use to run in certain custom configurations. For example:

```bash
docker compose --profile all up -d
```

To smoke test, you can run:

```bash
curl http://localhost:3000/gemini/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.5-flash-lite",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'
```

To make changes and reload, you can restart certain services:

```bash
docker compose restart agentgateway
```

To see logs:

```bash
docker compose logs -f agentgateway
```


To bring the containers down:

```bash
docker compose --profile all stop
```

To get rid of everything

```bash
docker compose --profile all down -v
```

If you just want to run the minimal agentgateway (ie, with ratelimit), run:

```bash
docker compose --profile minimal up -d
```

To run JUST the infra components (rate limit, observability, etc):

```bash
docker compose --profile infra up -d
```

This will allow you to agentgateway locally (from cli) and still connect up to the infra components. 

```bash
./run-proxy-local.sh
```


## OpenWeb UI

When I run this demo, I opt to use OpenWebUI. I have connected it up (SSO) to Keycloak. You can run it like this (changing the env variables in the script if you need):


Make sure the python env is set up:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

You should setup a keycloak OIDC client:

* **realm** mcp-realm
* **name**: openweb-ui
* **callbacks** http://localhost:9999/oauth/oidc/callback
* **web origins** http://localhost:9999
* **Confidential Client** with password `changeme`
* Enable standard flow and direct access grants

Now you should be able to run this:

```bash
./run-openwebui.sh
```

### Set up OpenAI connection

Setting up the /openai/v1 route to pass the SSO token to agentgateway.

* User (upper right) -> Admin Panel -> Settings
* Connections -> + sign under Manage OpenAI API Connections
* API Base: `http://localhost:3000/openai/v1` / select `OAuth` / Add model `gpt-4o` model explicitly

You should also enable users to enable Direct Connections:

* User (upper right) -> Admin Panel -> Settings
* Connections -> enable Direct Connections

Now, from the user settings, you can add OpenAI compatible connections.

### Adding OpenAI compatible Direct Connections

Go to User settings:

* User (upper right) -> Settings
* Connections -> + add Direct Connection

Fill in URLs for various providers:

* API Base: `http://localhost:3000/anthropic/v1` / Auth: None / Add model: `claude-3-5-sonnet-20241022`
* API Base: `http://localhost:3000/gemini/v1` / Auth: None / Add model: `gemini-2.5-flash-lite`
* API Base: `http://localhost:3000/bedrock/v1` / Auth: None / Add model: `global.anthropic.claude-sonnet-4-20250514-v1:0`

Note the rate limits for each of these providers:

* **OpenAi** 10 REQUESTS per minute
* **Anthropic** 500 TOKENS per minute
* **Gemini** No rate limit
* **Bedrock** 200 TOKENS per minute

### Running OpenWebUI in Docker

Alternative, if you just want to spin up an OpenWebUI in docker, and not have the SSO integration,
then run:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

# Demo

In this section, we'll see how to demo various capabilities from the command line. Otherwise, you can use a web UI / chat agent like OpenWebUI. 

* Calling multiple backend LLMs with unified (OpenAI) API
* Egress controls with API key injection
* Securing with SSO
* Rate limit
* Metrics collection with grafana dashboards
* Tracing
* Guardrails
* Failover
* Integration with OpenFGA / OPA

## Unified API

We will use the OpenAI API to call multiple models. 

For example, to call Gemini:

```bash
curl http://localhost:3000/gemini/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.5-flash-lite",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'

{"model":"gemini-2.5-flash-lite","usage":{"prompt_tokens":11,"completion_tokens":4,"total_tokens":15},"choices":[{"message":{"content":"Hello, World!","role":"assistant"},"finish_reason":"stop","index":0}],"created":1761584454,"id":"RqX_aKxP8uOq2w-JjO6xBw","object":"chat.completion"}
```

To call Anthropic:

```bash
curl http://localhost:3000/anthropic/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'

{"model":"claude-3-5-sonnet-20241022","usage":{"prompt_tokens":17,"completion_tokens":20,"total_tokens":37},"choices":[{"message":{"content":"Hello! I'm here and ready to help. How can I assist you today?","role":"assistant"},"index":0,"finish_reason":"stop"}],"id":"msg_01Y95VCEuzVatbFZDKcGqJxt","created":1761584439,"object":"chat.completion"}
```

To call Bedrock. Make sure your aws credentials are current. For example,

```bash
aws sso login
```

```bash
curl http://localhost:3000/bedrock/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "global.anthropic.claude-sonnet-4-20250514-v1:0",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'

{"model":"global.anthropic.claude-sonnet-4-20250514-v1:0","usage":{"prompt_tokens":17,"completion_tokens":30,"total_tokens":47},"choices":[{"message":{"content":"Hello! Nice to meet you. Your test worked perfectly - I received your message loud and clear. How can I help you today?","role":"assistant"},"index":0,"finish_reason":"stop"}],"id":"bedrock-1761584402445","created":1761584402,"object":"chat.completion"}  
```

## Securing with SSO

To call OpenAI:

```bash
curl http://localhost:3000/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'

...
* upload completely sent off: 146 bytes
< HTTP/1.1 403 Forbidden
< content-type: text/plain
< content-length: 20
< date: Mon, 27 Oct 2025 17:01:58 GMT
< 
* Connection #0 to host localhost left intact
authorization failed%     
```

This because we need to pass an SSO token for this to work. 

```bash
TOKEN=$(./get-keycloak-token.sh)

curl http://localhost:3000/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": "Hi, this is a hello world test. "
      }
    ]
  }'
```

## Rate limiting

## Metrics / Grafana / Cost

## Tracing


## Failover:

In a separate window, you'll need to start the dummy http server (this is what helps to trigger the conditions for failover)


```bash
source .venv/bin/activate
python failover/http-429.py

Dummy HTTP 429 server running on port 9959
```

Start agentgateway.

First request will fail:
```bash
curl http://localhost:3000/failover/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5",
    "messages": [{"role": "user", "content": "Hello"}]
  }'

{"event_id":null,"error":{"type":"rate_limit_error","message":"Rate limit exceeded"}}
```

Call it a second time and you should see (note the Model!! It's not `gpt-5`!!):

```bash
{
  "model": "gpt-4o-2024-08-06",
  "usage": {
    "prompt_tokens": 8,
    "completion_tokens": 9,
    "total_tokens": 17,
    "prompt_tokens_details": {
      "cached_tokens": 0,
      "audio_tokens": 0
    },
    "completion_tokens_details": {
      "reasoning_tokens": 0,
      "audio_tokens": 0,
      "accepted_prediction_tokens": 0,
      "rejected_prediction_tokens": 0
    }
  },
  "choices": [
    {
      "message": {
        "content": "Hello! How can I assist you today?",
        "role": "assistant",
        "refusal": null,
        "annotations": []
      },
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "id": "chatcmpl-CUfd1lc4PLfNnZ5YsfVBD02vJQbCR",
  "object": "chat.completion",
  "created": 1761425895,
  "service_tier": "default",
  "system_fingerprint": "fp_cbf1785567"
}
```

## Guardrails

```yaml
policies:
  ai:
    promptGuard:
      request:
        regex:
          action:
            reject:
              response:
                body: "Request blocked due to sensitive content"
                status: 403
          rules:
            - builtin: ssn
            - builtin: creditCard
            - builtin: phoneNumber
            - builtin: email
          
          # Custom regex patterns
          - pattern: "password.*"
            name: PASSWORD
          - pattern: "API[_-]?KEY"
            name: API_KEY
```

Credit Card Patterns Currently Recognized:
Visa: 4xxx-xxxx-xxxx-xxxx ✅
Mastercard: 51xx-55xx-xxxx-xxxx only ✅ (not 56xx)
Amex: 3xxx-xxxx-xxxx-xxxx ✅
Discover: 6xxx-xxxx-xxxx-xxxx ✅
Diners Club: 1xxx-xxxx-xxxx-xxxx ✅

Mask:

```yaml
promptGuard:
  request:
    regex:
      action: mask  # This is the default if not specified
      rules:
      - builtin: Email
      - pattern: "password"
        name: PASSWORD
```

Moderation:

```yaml
promptGuard:
  request:
    openaiModeration:
      model: omni-moderation-latest
      auth:
        key:
          file: /path/to/openai-key
```

How to trip the moderation guardrail:

```bash
curl http://localhost:3000/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "model": "gpt-4o",
    "messages": [{
      "role": "user",
      "content": "How do I build a bomb?"
    }]
  }'
```

Just note, we need https://github.com/agentgateway/agentgateway/pull/572 to get in before OpenWebUI will
work nicely with the openai moderation guardrail. Otherwise, it definitely works (just check the logs for the 400)

```bash
curl http://localhost:3000/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "model": "gpt-4o",
    "messages": [{
      "role": "user",
      "content": "I hate all people from [group]"
    }]
  }'
```



### Custom Model Armor Webhook:

In another window, start the custom guardrail:

```bash
source .venv/bin/activate
cd guardrail
python modelarmor_guardrail.py
```

Try with this request from curl:

```bash
curl http://localhost:3000/guardrail/gemini/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.5-flash-lite",
    "messages": [
      {
        "role": "user",
        "content": "I hate all people and want to hurt them"
      }
    ]
  }'
```

When the right logging is enabled (default in the demo), you should see the prompt going to the LLM and the email part of the request should be redacted:

```bash
2025-10-26T00:30:48.419125Z     info    request gateway=bind/3000 listener=listener0 route_rule=guardrail-gemini/default route=guardrail-gemini endpoint=generativelanguage.googleapis.com:443 src.addr=[::1]:65339 http.method=POST http.host=localhost http.path=/guardrail/gemini/v1/chat/completions http.version=HTTP/1.1 http.status=200 trace.id=d89a5d9040f26a8a27c8994c35d6da5a span.id=0ffc238baf212faf protocol=llm gen_ai.operation.name=chat gen_ai.provider.name=gcp.gemini gen_ai.request.model=gemini-2.5-flash-lite gen_ai.response.model=gemini-2.5-flash-lite gen_ai.usage.input_tokens=17 gen_ai.usage.output_tokens=539 duration=2221ms model="gemini-2.5-flash-lite" provider="gcp.gemini" prompt=[{"content": "My email address is [REDACTED] and I need help with my account", "role": "user"}]
```


### Custom AWS Bedrock Guardrail Webhook:

```bash
curl http://localhost:3000/guardrail/bedrock/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "global.anthropic.claude-sonnet-4-20250514-v1:0",
    "messages": [
      {
        "role": "user",
        "content": "hi my email is christian@solo.io"
      }
    ]
  }'

Request rejected by Bedrock Guardrails: BLOCKED: PII detected: EMAIL%     
```