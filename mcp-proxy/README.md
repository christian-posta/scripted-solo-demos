To run this demo:

(note, you may need to build the docker image)
> ./build-docker.sh

Next, you can fire up the proxy and the [mcp-inpsector](https://github.com/modelcontextprotocol/inspector); navigate to the right URL and list the tools:

```bash
./run-proxy.sh

# run this in a different window
npx @modelcontextprotocol/inspector
```

You can check the config files and talk through the config.

Do the same for openapi / petstore. This also shows the multi-plexing usecase / MCP federation

> ./run-proxy.sh openapi.json

Lastly, you can add Authz policies to the calls:

> ./run-proxy.sh auth.json

You will need the following key:

eyJhbGciOiJFUzI1NiIsImtpZCI6IlhoTzA2eDhKaldIMXd3a1dreWVFVXhzb29HRVdvRWRpZEVwd3lkX2htdUkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJtZS5jb20iLCJleHAiOjE5MDA2NTAyOTQsImlhdCI6MTc0NDczNDA5NiwiaXNzIjoibWUiLCJqdGkiOiI5MTU0MmI5NWFkYWE1MzRiNTgxZGU5MTUyYWRlZDY1MGQ0NGJiNGI3YjJmZjFmM2M4NGU2M2YwNWE4ZTNiMjMxIiwibmJmIjoxNzQ0NzM0MDk2LCJzdWIiOiJtZSJ9.jXoHVVvTbXb27JhTJVATqgSQ30lQXNIL3aGxgucujgRHHlTBajUJIjjwC5mvfyy274YGNiAinf-fMYieUGi3Pw

