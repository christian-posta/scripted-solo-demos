# Agentgateway Demo


## LLM usecases
* Calling multiple backend LLMs with unified (OpenAI) API
* Egress controls with API key injection
* Securing with SSO
* Rate limit
* Metrics collection with grafana dashboards
* Tracing
* Guardrails
* Failover
* Policy enforcement
* Integration with OpenFGA / OPA

Demo through CLI and UI. 

The models we use in this demo:

* OpenAI: gpt-4o 
* Anthropic: claude-3-5-sonnet-20241022
* Gemini: gemini-2.5-flash-lite
* Bedrock: global.anthropic.claude-sonnet-4-20250514-v1:0

## MCP Usecases

Fill this in

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

Each model is configured with rate limiting. Right now, it's set to x-Per-Minute.

The rate limiting is the same as Envoy. The proxy/gateway sends in descriptors, and the rate limit server is configured to match descriptors and enforce rate limit policy on that. For example, let's look at the OpenAI route.

OpenAI route (ie, `/openai`) has the following configuration in agentgateway:

```yaml
    remoteRateLimit:
      domain: "agentgateway"
      host: "${RATELIMIT_HOST:-localhost}:8081"
      descriptors:
        - entries:
            - key: "route"
              value: '"openai"'
          type: "requests"
```

This is a remote / global rate limit config (alternative is local rate limit - https://agentgateway.dev/docs/configuration/resiliency/rate-limits/#local). 

It basically creates a descriptor (ie, set of metadata) with a key of "route" and a value of "openai". This is expected to be treated as a "request rate limit" (vs token rate limit which we'll cover in a bit). 

The rate limit server is configured like this (`.config/ratelimit-config.yaml`):

```yaml
descriptors:
  # Global rate limit for OpenAI route - 1 request per minute
  - key: route
    value: "openai"
    rate_limit:
      unit: minute
      requests_per_unit: 10
```

This means, for a request that comes in with descriptors that match here (ie, route == openai) then we'll apply a 10 request per minute. 

Anthropic is configured slightly differently:

```yaml
    remoteRateLimit:
      domain: "agentgateway"
      host: "${RATELIMIT_HOST:-localhost}:8081"
      descriptors:
        - entries:
            - key: "route"
              value: '"anthropic"'
          type: "tokens"      
```

Same idea, but instead of REQUESTS, we are using TOKENS. The RLS config is:

```yaml
  - key: route
    value: "anthropic"
    rate_limit:
      unit: minute
      requests_per_unit: 500
```

This means anthropic has 500 tokens per minute rate limiting enforced. 

Here are the routes rate limit configs for the demo:


| Route      | Limit                  | Unit    | Type    |
|------------|------------------------|---------|---------|
| openai     | 10 requests            | minute  | requests|
| anthropic  | 500 tokens             | minute  | tokens  |
| gemini     | 500 tokens             | minute  | tokens  |
| bedrock    | 200 tokens             | minute  | tokens  |
| mcp        | 100 tokens             | minute  | tokens  |

_Note 1: "requests" type means X full API requests per minute, while "tokens" means X tokens (total input+output) per minute._

_Note 2: at the time of writing, we don't send descriptors from the gateway to the RLS for the gemini/bedrock/mcp routes. So those wont actually have RL enforced._

_Note 3: for anthropic, we enable the `tokenize` setting which means agw will do estimations for tokens on the prompt request and then do a true-up afterward. otherwise, if tokenize is not set, then rate limit true up happens only after the actual token usage is returned (response) from the LLM_

To exercise the rate limit, try send more than 10 requests to OpenAI, or a large prompt to Anthropic. 


## Metrics / Grafana / Cost

Grafana default un/pw: `admin`/`admin`
You may be prompted to change pw, just keep it the same. 

Agentgateway exposes metrics on:

```bash
curl http://localhost:15020/metrics 
```

We connect this up to prometheus (see `./config/prometheus.yml`)

This is used to populate two main grafana dashboards.

Grafana is exposed on `http://localhost:3001/`

![Grafana Dashboards List](./images/dashboard-list.png)

The cost dashboard shows breakdown of model usage, pricing. This can be broken down by team, user, organiziation, anything you want. 

![Model Cost Dashboard](./images/cost.png)

And you can also get operational / usage information from the metrics:

![Ops Dashboard 1](./images/operations1.png)
![Ops Dashboard 2](./images/operations2.png)

## Tracing

Tracing is Open Telemetry style tracing, configured on the gateway like this:

```bash
tracing:
  otlpEndpoint: "http://host.docker.internal:4317"
  randomSampling: 'true'  # String 'true' means always sample (100%)
  fields:
    add:
      authenticated: 'jwt.sub != null'
      gen_ai.system: 'llm.provider'
      gen_ai.request.model: 'llm.request_model'
      gen_ai.response.model: 'llm.response_model'
      gen_ai.usage.input_tokens: 'llm.input_tokens'
      gen_ai.usage.output_tokens: 'llm.output_tokens'
      gen_ai.operation.name: '"chat"'        
```

If you go to the dashboard: `http://localhost:16686` you can see the traces:

![Jaeger traces list](./images/tracing1.png)

Clicking on one of the traces, you can see more details about the trace:

![Specific trace](./images/specific-trace.png)

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

Which routes have which guardrails?

* OpenAI (`/openai`): `builtin`, `openai-moderation`
* Anthropic (`/anthropic`): `builtin`
* Gemini-guardrail (`/guardrail/gemini`): custom webhook calling model armor
* Bedrock-guardrail (`/guardrail/bedrock`): custom webhook calling AWS bedrock


We can use built-in guardrails (regex based, inline in the proxy, no-callout):

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
```

Credit Card Patterns Currently Recognized:
Visa: 4xxx-xxxx-xxxx-xxxx ✅
Mastercard: 51xx-55xx-xxxx-xxxx only ✅ (not 56xx)
Amex: 3xxx-xxxx-xxxx-xxxx ✅
Discover: 6xxx-xxxx-xxxx-xxxx ✅
Diners Club: 1xxx-xxxx-xxxx-xxxx ✅

How to trip the builtin guardrail:

```bash
curl http://localhost:3000/anthropic/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "messages": [{
      "role": "user",
      "content": "What would you do with a sensitive card number like 5100 4567 8901 2345"
    }]
  }'

{"model":"claude-3-5-sonnet-20241022","usage":{"prompt_tokens":24,"completion_tokens":41,"total_tokens":65},"choices":[{"message":{"content":"I aim to keep all information secure and private. I do not store, share, or process sensitive data like credit card numbers. I aim to handle such information responsibly and securely.","role":"assistant"},"index":0,"finish_reason":"stop"}],"id":"msg_01Lnw3wm1SnANPqhcQpweU9Z","created":1761598517,"object":"chat.completion"}
```

You can check whether the prompt was masked by looking at the agentgateway logs:

```bash
agentgateway-1  | 2025-10-27T20:55:17.812531Z   info    request gateway=bind/3000 listener=listener0 route_rule=anthropic-claude/default route=anthropic-claude endpoint=api.anthropic.com:443 src.addr=192.168.65.1:25678 http.method=POST http.host=localhost http.path=/anthropic/v1/chat/completions http.version=HTTP/1.1 http.status=200 trace.id=1fc69b6187743c03e5f3f64d8c1ef583 span.id=f7bbb360ff792ea2 protocol=llm gen_ai.operation.name=chat gen_ai.provider.name=anthropic gen_ai.request.model=claude-3-5-sonnet-20241022 gen_ai.response.model=claude-3-5-sonnet-20241022 gen_ai.usage.input_tokens=24 gen_ai.usage.output_tokens=41 duration=1695ms model="claude-3-5-sonnet-20241022" provider="anthropic" prompt=[{"role": "user", "content": "What would you do with a sensitive card number like <CREDIT_CARD>"}]
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
TOKEN=$(./get-keycloak-token.sh)

curl http://localhost:3000/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-4o",
    "messages": [{
      "role": "user",
      "content": "How do I build a bomb?"
    }]
  }'

{
  "error": {
    "message": "Your request was rejected by our content moderation system",
    "type": "invalid_request_error",
    "code": "content_policy_violation"
  }
}    
```

Just note, we need https://github.com/agentgateway/agentgateway/pull/572 to get in before OpenWebUI will
work nicely with the openai moderation guardrail. Otherwise, it definitely works (just check the logs for the 400)


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

Request rejected by Model Armor: BLOCKED: RAI policy violation%   
```

You can see in the custom guardrail log:

```bash
025-10-27 13:57:02,571 - __main__ - INFO - Validating user prompt with Model Armor (role=user)
2025-10-27 13:57:03,475 - __main__ - INFO - Model Armor user_prompt result: filterMatchState=MATCH_FOUND
2025-10-27 13:57:03,476 - __main__ - WARNING - RAI filter violation detected: {'executionState': 'EXECUTION_SUCCESS', 'matchState': 'MATCH_FOUND', 'raiFilterTypeResults': {'dangerous': {'confidenceLevel': 'HIGH', 'matchState': 'MATCH_FOUND'}, 'harassment': {'confidenceLevel': 'HIGH', 'matchState': 'MATCH_FOUND'}, 'hate_speech': {'confidenceLevel': 'MEDIUM_AND_ABOVE', 'matchState': 'MATCH_FOUND'}, 'sexually_explicit': {'matchState': 'NO_MATCH_FOUND'}}}
2025-10-27 13:57:03,476 - __main__ - INFO - Violations detected: ['rai'], blocking_mode=strict, should_block=True
2025-10-27 13:57:03,476 - __main__ - INFO - Model Armor decision: should_block=True, has_sanitized_content=False, reason=BLOCKED: RAI policy violation
2025-10-27 13:57:03,481 - __main__ - WARNING - REQUEST BLOCKED by Model Armor: BLOCKED: RAI policy violation
2025-10-27 13:57:03,482 - werkzeug - INFO - 127.0.0.1 - - [27/Oct/2025 13:57:03] "POST /request HTTP/1.1" 200 -
```

When the right logging is enabled on agentgateway (default in the demo), you should see the prompt going to the LLM and the email part of the request should be redacted:

```bash
2025-10-26T00:30:48.419125Z     info    request gateway=bind/3000 listener=listener0 route_rule=guardrail-gemini/default route=guardrail-gemini endpoint=generativelanguage.googleapis.com:443 src.addr=[::1]:65339 http.method=POST http.host=localhost http.path=/guardrail/gemini/v1/chat/completions http.version=HTTP/1.1 http.status=200 trace.id=d89a5d9040f26a8a27c8994c35d6da5a span.id=0ffc238baf212faf protocol=llm gen_ai.operation.name=chat gen_ai.provider.name=gcp.gemini gen_ai.request.model=gemini-2.5-flash-lite gen_ai.response.model=gemini-2.5-flash-lite gen_ai.usage.input_tokens=17 gen_ai.usage.output_tokens=539 duration=2221ms model="gemini-2.5-flash-lite" provider="gcp.gemini" prompt=[{"content": "My email address is [REDACTED] and I need help with my account", "role": "user"}]
```


### Custom AWS Bedrock Guardrail Webhook:

In another window, start the custom guardrail:

```bash
source .venv/bin/activate
cd guardrail
python bedrock_guardrail.py
```

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

Blocked by agentgateway:

```bash
agentgateway-1  | 2025-10-27T20:58:35.533149Z   info    request gateway=bind/3000 listener=listener0 route_rule=guardrail-bedrock/default route=guardrail-bedrock endpoint=bedrock-runtime.us-west-2.amazonaws.com:443 src.addr=192.168.65.1:17930 http.method=POST http.host=localhost http.path=/guardrail/bedrock/v1/chat/completions http.version=HTTP/1.1 http.status=403 trace.id=2db600da1ce3aa6fdaf0d96518a6d9e7 span.id=51f31aa3a91056a4 protocol=llm duration=2163ms
```

Guardrail logs:

```bash
2025-10-27 13:58:33,372 - __main__ - INFO - Validating user prompt with Bedrock Guardrails (1 messages)
2025-10-27 13:58:35,528 - __main__ - INFO - Bedrock input result: action=GUARDRAIL_INTERVENED
2025-10-27 13:58:35,528 - __main__ - WARNING - PII violation (blocked): EMAIL
2025-10-27 13:58:35,528 - __main__ - INFO - Violations detected: ['pii:EMAIL']
2025-10-27 13:58:35,529 - __main__ - INFO - Blocked: ['pii:EMAIL'], Anonymized: []
2025-10-27 13:58:35,529 - __main__ - INFO - Blocking mode: strict, should_block: True
2025-10-27 13:58:35,529 - __main__ - INFO - Bedrock decision: should_block=True, has_masked_content=True, reason=BLOCKED: PII detected: EMAIL
2025-10-27 13:58:35,529 - __main__ - WARNING - REQUEST BLOCKED by Bedrock Guardrails: BLOCKED: PII detected: EMAIL
2025-10-27 13:58:35,530 - werkzeug - INFO - 127.0.0.1 - - [27/Oct/2025 13:58:35] "POST /request HTTP/1.1" 200 -
```

## Policy Enforcement

We can use JWT tokens to enforce fine-grained policy for calling certain LLMs. For example, we have two different users:

`mcp-user`:

```bash
./get-keycloak-token.sh mcp-user
```

example:
> TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQNGMtZ3pxRDdfUDVteTI1SmNFdkJkSmx0UlQ5OWdwSndoZDFVZUxGVTlVIn0.eyJleHAiOjE3NjE2MDMzMTAsImlhdCI6MTc2MTU5OTcxMCwianRpIjoib25ydHJvOmFlMzgwMTdjLWY5NWQtNGY4YS05YTFiLTE4ZjdjOWQxZmU2YSIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9yZWFsbXMvbWNwLXJlYWxtIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImU1ODcwNGQ2LWRhZWEtNGM3NS04NDhkLWIxY2ZiNjgxOTAxNSIsInR5cCI6IkJlYXJlciIsImF6cCI6Im9wZW53ZWItdWkiLCJzaWQiOiJkM2NmZmViZC01OTE0LTQ0MDUtYTNiZS05Y2QwNDg1N2FjYWMiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHA6Ly9sb2NhbGhvc3Q6OTk5OSJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsic3VwcGx5LWNoYWluIiwiZGVmYXVsdC1yb2xlcy1tY3AtcmVhbG0iLCJhaS1hZ2VudHMiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJNQ1AgVXNlciIsInByZWZlcnJlZF91c2VybmFtZSI6Im1jcC11c2VyIiwiZ2l2ZW5fbmFtZSI6Ik1DUCIsImZhbWlseV9uYW1lIjoiVXNlciIsImVtYWlsIjoidXNlckBtY3AuZXhhbXBsZS5jb20ifQ.Bxg5-YT7rD5G8n6d-SLTS34hpQKRYenp8EVm51kkJajOO-txx6efJYuLteSrgmhSD8EP__FAR28quiycdKD5FqiPZPpMoFZE3uSwIzjdZEkOW-t0N4Y2GgwTFr7i4joj-449O-YuORUG36Q8QTOs33VXWY_ElVjKtqTp6DOVKwWJjJC-2dX1e9l2i6NDWzifs6Zhpr6VfNJ3FjoTikCGHW_Ntf9xRMSZ72BTJ80JFfA_c5bi1AePofk1b8dmd9f3eo9yDo71Zy1km0YUqbIPdZbUflEgPvoAE2KSU07E_K45OjDTLMBsuu4sENiRW-4axnEXw65OGbNpCdhkcB3MCA

```json
{
  "exp": 1761603310,
  "iat": 1761599710,
  "jti": "onrtro:ae38017c-f95d-4f8a-9a1b-18f7c9d1fe6a",
  "iss": "http://localhost:8080/realms/mcp-realm",
  "aud": "account",
  "sub": "e58704d6-daea-4c75-848d-b1cfb6819015",
  "typ": "Bearer",
  "azp": "openweb-ui",
  "sid": "d3cffebd-5914-4405-a3be-9cd04857acac",
  "acr": "1",
  "allowed-origins": [
    "http://localhost:9999"
  ],
  "realm_access": {
    "roles": [
      "supply-chain",
      "default-roles-mcp-realm",
      "ai-agents",
      "offline_access",
      "uma_authorization"
    ]
  },
  "resource_access": {
    "account": {
      "roles": [
        "manage-account",
        "manage-account-links",
        "view-profile"
      ]
    }
  },
  "scope": "profile email",
  "email_verified": true,
  "name": "MCP User",
  "preferred_username": "mcp-user",
  "given_name": "MCP",
  "family_name": "User",
  "email": "user@mcp.example.com"
}
```

`other-user`:

```bash
./get-keycloak-token.sh other-user
```

example:

> TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQNGMtZ3pxRDdfUDVteTI1SmNFdkJkSmx0UlQ5OWdwSndoZDFVZUxGVTlVIn0.eyJleHAiOjE3NjE2MDMzNDIsImlhdCI6MTc2MTU5OTc0MiwianRpIjoib25ydHJvOjZhZDc1ZmRlLTU3NzktNDY3Ni1iMjViLTdiODIwMTg2NDI3MSIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9yZWFsbXMvbWNwLXJlYWxtIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjJmZWRmNWRmLTk3MTgtNGNlNy1iZTM4LTUyMmVhZmE3ZDdjNCIsInR5cCI6IkJlYXJlciIsImF6cCI6Im9wZW53ZWItdWkiLCJzaWQiOiI5NzkyN2NkNS1jYWFlLTQzZmItOWNjZi02ZTcwYmJhNGQwYWQiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHA6Ly9sb2NhbGhvc3Q6OTk5OSJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiZGVmYXVsdC1yb2xlcy1tY3AtcmVhbG0iLCJhaS1hZ2VudHMiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJPdGhlciBVc2VyIiwicHJlZmVycmVkX3VzZXJuYW1lIjoib3RoZXItdXNlciIsImdpdmVuX25hbWUiOiJPdGhlciIsImZhbWlseV9uYW1lIjoiVXNlciIsImVtYWlsIjoib3RoZXJAbWNwLmV4YW1wbGUuY29tIn0.DNI5rpFwvkZRcp1mJrktvLWc20p1teSrN9A26-Wnq5v2wTJHkX1mA5G7rZUKA_YL-gST4lK9yUWuO3DV7iJO5TsQuieCtV8mjPa7_p3UwpwvnoWQPCTSmYnUYJPcL7gNsj8fOcpKWnbtvO68WXQQGL9igqlVXcCR9nkMQNceLvmH8cHmTOPVjcbWdNriitWgHxZIxy0zIgMWiqzwYZ0N34IeHoERKfT4_prstB63Gb5kNwhn4IWgGudNq9_O9-BhuF0LeFh0o2kt-JjUDcSyeYpnnAe1QPQgxsqQzbOHGty2ndSs78R8iWYmB19R4YwDK1-wdWz7HLS9zw3AiHEsNg

```json
{
  "exp": 1761603342,
  "iat": 1761599742,
  "jti": "onrtro:6ad75fde-5779-4676-b25b-7b8201864271",
  "iss": "http://localhost:8080/realms/mcp-realm",
  "aud": "account",
  "sub": "2fedf5df-9718-4ce7-be38-522eafa7d7c4",
  "typ": "Bearer",
  "azp": "openweb-ui",
  "sid": "97927cd5-caae-43fb-9ccf-6e70bba4d0ad",
  "acr": "1",
  "allowed-origins": [
    "http://localhost:9999"
  ],
  "realm_access": {
    "roles": [
      "default-roles-mcp-realm",
      "ai-agents",
      "offline_access",
      "uma_authorization"
    ]
  },
  "resource_access": {
    "account": {
      "roles": [
        "manage-account",
        "manage-account-links",
        "view-profile"
      ]
    }
  },
  "scope": "profile email",
  "email_verified": true,
  "name": "Other User",
  "preferred_username": "other-user",
  "given_name": "Other",
  "family_name": "User",
  "email": "other@mcp.example.com"
}
```

You can see these users have different roles. That is, the mcp-user has `supply-chain` role, while the other user. Does not. If we set our policy like this:

```yaml
        authorization:
          rules:
            - "request.method == 'OPTIONS'"  # Allow OPTIONS
            - "jwt.sub != null && 'supply-chain' in jwt.realm_access.roles"          
```

Then we will only allow the users in the supply-chain role through to call this route.

```bash
curl http://localhost:3000/policy/openai/v1/chat/completions \
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

# Will see this if using the JWT w/o the supply-chain role
authorization failed%
```


## OPA Policy Enforcement

You will need to start the OPA ext_auth server:

```bash
cd ./policy/opa-policy-engine
./run-opa.sh
```

_Note: this will run on port 8181 (http) and 9191 (grpc)_

Take a look at `./policy/opa-policy-engine/policies/authz.rego` for the policy, which restricts models to those that start with gpt-3.5* and requires a specific header `x-opa-passthrough-enabled: true`. 

Keep in mind, the execution engine evaluates in this order:

| Confirmed execution order:                                      |
|---------------------------------------------------------------|
| JWT validation (lines 53-56)                                  |
| ext_authz (lines 58-63) ← YOUR PR adds body support here      |
| Authorization (CEL) (lines 70-72)                             |
| Local rate limit (lines 75-77)                                |
| Remote rate limit (lines 79-86)                               |
| ext_proc (lines 88-93)                                        |
| Transformation (lines 95-97) ← This is AFTER ext_authz        |
| CSRF (lines 99-103)                                           |

Which means, we can do things like validate JWT before sending to ext_authz. The only problem at the moment is that JWT validation removes the JWT from the headers, so ext_authz won't see it (https://github.com/agentgateway/agentgateway/issues/576). We could try xform with cel to put into headers, but as you can see xformation happens after ext_authz. 

We will also want body support in the policy engine. So we should optionally include the body (https://github.com/agentgateway/agentgateway/pull/578)

_Note: Until the https://github.com/agentgateway/agentgateway/pull/578 is fixed, we may not be able to demo this very well_

Should deny this:

```bash
curl http://localhost:3000/opa/openai/v1/chat/completions \
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
```


Should allow this since it has an allowed body, and has the right header. 

```bash
curl -X POST http://localhost:3000/opa/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "x-opa-passthrough-enabled: true" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hi, this is a hello world test."}]
  }'
```