## Basic Example

This example shows how to use the mcp-proxy to proxy requests A2A requests.

### Running the example

```bash
cargo run -- -f examples/a2a/config.json
```

Let's look at the config to understand what's going on. First off we have a listener, which tells the proxy how to listen for incoming requests/connections. In this case we're using the `a2a` listener, which is a simple HTTP listener that listens on port 3000.

```json
  "listener": {
    "a2a": {
      "host": "0.0.0.0",
      "port": 3000
    }
  }
```

Next we have a targets section, which tells the proxy how to proxy the incoming requests.
In this case, we are proxying to an agent we have named `google_adk`, listening on port 10002.
To run this yourself, follow the [sample documentation](https://github.com/google/A2A/tree/main/samples/python/agents/google_adk).

```json
  "targets": [
    {
      "name": "google_adk",
      "a2a": {
        "host": "127.0.0.1",
        "port": "10002"
      }
    }
  ]
```

To test this, we can run the sample [`a2a` CLI](https://github.com/google/A2A/tree/main/samples/python/hosts/cli)

```bash
uv run hosts/cli --agent http://localhost:3000/google_adk
```

From here, you can send requests through the CLI and view them being proxied.
