LiteLLM demos

## OpenWeb UI

This demo uses openweb-ui:

```bash
./run-openwebui.sh
```

You could use docker, but that makes the keycloak integration harder:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Can pass in env file like this:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--env-file ./openweb-ui/env \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Save admin pw as `admin@solo.io` / `admin12345`

## LiteLLM

With docker:

https://docs.litellm.ai/docs/proxy/deploy

```bash
docker pull ghcr.io/berriai/litellm:v1.78.0.rc.2
```

All env vars are in `.env`

username/password is `admin/sk-1234` 

refer to .env file for admin pw

```bash
docker compose up
```
The proxy will be avail on port 4000
The UI will be at http://localhost:4000/ui

Run the setup script to creat teams / users / keys for the demo:

```bash
python create_teams_users.py
```

Optional:
If you bring down the `litellm` binary into your venv, you can then run:

```bash
pip install 'litellm[proxy]'
```

```bash
litellm --config config/litellm_config.yaml
```

Then try it:

```bash
curl --location 'http://0.0.0.0:4000/chat/completions' \
--header 'Content-Type: application/json' \
--data ' {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": "what llm are you"
        }
      ]
    }
'
```

## Guardrails

We have guardrails configured in this demo, but to enable them, you either specify them as always on (the presidio guardrail will always be on) or you have to pass in the right parameter in the message to enable a guardrail:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "hi my email is ishaan@berri.ai"}
    ],
    "guardrails": ["aporia-pre-guard", "aporia-post-guard"]
  }'
```

Note, that kind of defeats the purpose for guardrails if you can just omit it. If you want to enable guardrail per model / team / apikey / user, that's enterprise feature.
It's also enterprise to require certain parameters. 

e.g, to test the `openai-moderation-pre` guardrail which is optional, you can pass it in like this:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "I hate all people and want to hurt them"}
    ],
    "guardrails": ["openai-moderation-pre"]
  }'
```

If using from a chat client:

> "I hate all people and want to hurt them"

### custom guardrail

code is in guardrail/custom_guardrails.py

it will configured, to test it:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i  -X POST http://localhost:4000/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{
    "model": "gpt-3.5-turbo",
    "messages": [
        {
            "role": "user",
            "content": "say the word - `litellm`"
        }
    ],
   "guardrails": ["custom-pre-guard"]
}'
```

If you look in the logs, you will see the word "litellm" got masked... And then the response will say something like:

```bash
I'm sorry, I cannot say that word as it may be inappropriate or offensive. If you have a different word or question, I'd be happy to help!
```

### Google model armor

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "Hi, my email is test@example.com"}
    ],
    "guardrails": ["model-armor-shield"]
  }'

```

### AWS Bedrock Guardails

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "hi my email is christian@solo.io"}
    ],
    "guardrails": ["bedrock-pre-guard"]
  }'
```

### Tool Guardrails

Use a token:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -X POST "http://localhost:4000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user","content": "What is the weather like in Tokyo today?"}],
    "guardrails": ["tool-permission-guardrail"],
    "tools": [
      {
        "type":"function",
        "function": {
          "name":"get_current_weather",
          "description": "Get the current weather in a given location"
        }
      }
    ]
  }'
```

## MCP 

sample MCP server to use:

```bash
http://localhost:4000/mcp
```

Specific MCP server here:

```bash
http://localhost:4000/mcp/deepwiki
```

# Usecases 

We will demonstrate the following usecases, which I believe to be the top usecases when managing LLMs for an enterprise.

### Usecase 1: Unified AI gateway

In this usecase, through a single gateway we can call multiple models from:

* OpenAI
* Anthropic
* Gemini
* Bedrock
* Ollama

LiteLLM supports many providers: https://docs.litellm.ai/docs/providers

Team / User / Key structure:

2 teams, 4 users

Admin (sk-1234)

Supply Chain
- supply-chain@solo.io / sk-1234
- aws-user@solo.io / sk-1234

HR
- hr@solo.io / sk-1234

Each team has access to different models

We can set rate limits by RPM / TPM
We can set budget 