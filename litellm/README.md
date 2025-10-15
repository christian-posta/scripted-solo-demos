LiteLLM demos

## OpenWeb UI

This demo uses openweb-ui:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Save admin pw as `admin@solo.io` / `admin12345`

## LiteLLM

With docker:

https://docs.litellm.ai/docs/proxy/deploy

```bash
docker pull ghcr.io/berriai/litellm:v1.78.0.rc.2
```

If you bring down the `litellm` binary into your venv, you can then run:

```bash
pip install 'litellm[proxy]'
```

```bash
litellm --config config/openai.yaml
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

