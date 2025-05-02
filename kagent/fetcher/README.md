To get this tool deployed, deploy it first:

```bash
kubectl apply -f fetcher/deployment.yaml
```

you can go the UI and add the tool server at the following URL:


```bash
http://mcp-website-fetcher.kagent.svc.cluster.local/sse
```

Alternatively, you can create the following tool server:

```bash
kubectl apply -f fetcher/toolserver.yaml
```

You can then build an agent that uses the fetcher tool; then use a prompt in the Agent chat like this:

Show me the contents of https://en.wikipedia.org/wiki/Service_mesh website