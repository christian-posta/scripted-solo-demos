Run it with

```bash
./run-opa.sh
```

Check `example-attributes.json` for the structure of how agentgateway sends ext_authz. For example:

```rego
# Access source IP
source_ip := input.attributes.source.address.socketAddress.address

# Access HTTP method  
http_method := input.attributes.request.http.method

# Access path
http_path := input.attributes.request.http.path

# Access headers
get_header(name) := input.attributes.request.http.headers[name]

# Access context extensions
get_context(name) := input.attributes.contextExtensions[name]

# Access TLS info (if present)
sni := input.attributes.tlsSession.sni
```
