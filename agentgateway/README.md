# Agentgateway Demo

* Calling multiple backend LLMs with unified (OpenAI) API
* Egress controls with API key injection
* Securing with SSO
* Rate limit
* Failover
* Guardrails



## OpenWeb UI

When I run this demo, I opt to use OpenWebUI. I have connected it up (SSO) to Keycloak. You can run it like this (changing the env variables in the script if you need):


Make sure the python env is set up:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

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

## Demoing MCP

