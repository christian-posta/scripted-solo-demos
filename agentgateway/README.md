# Agentgateway Demo

* Calling multiple backend LLMs with unified (OpenAI) API
* Egress controls with API key injection
* Securing with SSO
* Rate limit
* Metrics collection with grafana dashboards
* Tracing
* Guardrails
* Failover


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

To make changes and reload, you can restart certain services:

```bash
docker compose restart agentgateway
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

