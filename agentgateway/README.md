To run this demo:
> ./build-docker.sh

Next, you can fire up the proxy and the [mcp-inpsector](https://github.com/modelcontextprotocol/inspector); navigate to the right URL and list the tools:

```bash
./run-proxy.sh

# run this in a different window
npx @modelcontextprotocol/inspector
```

You can check the config files and talk through the config.

Do the same for openapi / petstore. This also shows the multi-plexing usecase / MCP federation

```bash
./run-proxy.sh resources/openapi.json
```

Lastly, you can add Authz policies to the calls:

```bash
./run-proxy.sh resources/auth.json
```

You will need the following key:

eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw


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

Note that the A2A listener should be on port `5555` since that's what we map when we start the docker container. 

Start the langgraph A2A agent on localhost:10000, and in the target, refer to it as `host.docker.internal:10000`