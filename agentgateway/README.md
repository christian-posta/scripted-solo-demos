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

Alternative, you can run it directly without the keycloak/SSO integration

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

If you need to pass env variables to it:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--env-file ./openweb-ui/env \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```


