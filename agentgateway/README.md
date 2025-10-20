
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




To run this demo and step by step explore agent gateway:

```bash
./demo.sh
```

Next, you can fire up the proxy and the [mcp-inpsector](https://github.com/modelcontextprotocol/inspector); navigate to the right URL and list the tools:

```bash
agentgateway -f resources/basic.yaml

# run this in a different window
npx @modelcontextprotocol/inspector
```

You can check the config files and talk through the config.



You can also run from docker:


```bash
./run-proxy.sh resources/auththorization.yaml
```

You will need the following key:

```bash
eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJ0ZXN0LmFnZW50Z2F0ZXdheS5kZXYiLCJleHAiOjE5MDA2NTAyOTQsImZpZWxkMSI6InZhbHVlMSIsImlhdCI6MTc1MTU1ODA2MCwiaXNzIjoiYWdlbnRnYXRld2F5LmRldiIsImp0aSI6ImU2NTE2NjgyNTllMDVhOTczYTBiNDA4Mzk1ZGFlYzQyMDg1MmFjOTJmOTg3MTdlMzc1OTQyOWRiMWNhYzg3NjIiLCJsaXN0IjpbImFwcGxlIiwiYmFuYW5hIl0sIm5iZiI6MTc1MTU1ODA2MCwibmVzdGVkIjp7ImtleSI6InZhbHVlIn0sInN1YiI6InRlc3QtdXNlciJ9.4fJ9wGDflGOlJJMvdZdc0323qwxvP93mhtaJrvqvTSWDCuF5fzPOYuYAWEWrFhsEJFjxiBLlNlDYrUu4mQ1aVw

```


### Metrics / Tracing
NOTE: The tracing JSON config refers to host.docker.internal for Mac / Docker Desktop. On linux, you should use the bridge network 172.17.0.1
To run the metrics/tracing example:

Run Jaeger:

```bash
docker compose up
```

You can open Jaeger on:

```bash
http://localhost:16686
```

### A2A demo


This is the demo:
https://github.com/google/A2A/tree/main/samples/python/

```bash
uv run agents/helloworld  
```

To run the client and point to agent gateway (or go to agw playground)

```bash
uv run hosts/cli --agent http://localhost:3000 
```

If using docker and the UI playground:

Start the langgraph A2A agent on localhost:3000 (default), and in the target, refer to it as `host.docker.internal:3000`