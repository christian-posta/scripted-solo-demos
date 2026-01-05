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

The OPA decision input will look like this:

```json
{
   "decision_id":"4c20c9e5-4b16-4a0b-b4f8-c9d36b06da92",
   "input":{
      "attributes":{
         "contextExtensions":{
            "environment":"development",
            "region":"us-west-1",
            "service":"agentgateway"
         },
         "destination":{
            "address":{
               "socketAddress":{
                  "address":"172.19.0.7",
                  "portValue":3000
               }
            }
         },
         "metadataContext":{
            "filterMetadata":{
               "envoy.filters.http.jwt_authn":{
                  "jwt_payload":{
                     "acr":"1",
                     "allowed-origins":[
                        "http://localhost:9999"
                     ],
                     "aud":"account",
                     "azp":"openweb-ui",
                     "email":"user@mcp.example.com",
                     "email_verified":true,
                     "exp":1767650079,
                     "family_name":"User",
                     "given_name":"MCP",
                     "iat":1767646479,
                     "iss":"http://localhost:8080/realms/mcp-realm",
                     "jti":"onrtro:293c632d-cfaf-4e28-8609-b453d87506c9",
                     "name":"MCP User",
                     "preferred_username":"mcp-user",
                     "realm_access":{
                        "roles":[
                           "supply-chain",
                           "default-roles-mcp-realm",
                           "ai-agents",
                           "offline_access",
                           "uma_authorization"
                        ]
                     },
                     "resource_access":{
                        "account":{
                           "roles":[
                              "manage-account",
                              "manage-account-links",
                              "view-profile"
                           ]
                        }
                     },
                     "scope":"profile email",
                     "sid":"0da0011f-8611-4a67-a20c-e1fed6249dae",
                     "sub":"e3349fa1-02c5-4d80-b497-4e7963b20148",
                     "typ":"Bearer"
                  }
               }
            }
         },
         "request":{
            "http":{
               "body":"{\n    \"model\": \"gpt-3.5-turbo\",\n    \"messages\": [{\"role\": \"user\", \"content\": \"Hi, this is a hello world test.\"}]\n  }",
               "headers":{
                  "accept":"*/*",
                  "content-length":"116",
                  "content-type":"application/json",
                  "traceparent":"00-7c0f0f833eef36062b3fe9d11f8ade7e-8e8bb6c8bfd28f4f-01",
                  "user-agent":"curl/8.7.1",
                  "x-opa-passthrough-enabled":"true"
               },
               "host":"localhost",
               "id":"7c0f0f833eef36062b3fe9d11f8ade7e",
               "method":"POST",
               "path":"/opa/openai/v1/chat/completions",
               "protocol":"HTTP/1.1",
               "scheme":"http"
            },
            "time":{
               "nanos":364547674,
               "seconds":1767646487
            }
         },
         "source":{
            "address":{
               "socketAddress":{
                  "address":"172.64.150.238",
                  "portValue":21186
               }
            }
         }
      },
      "parsed_body":{
         "messages":[
            {
               "content":"Hi, this is a hello world test.",
               "role":"user"
            }
         ],
         "model":"gpt-3.5-turbo"
      },
      "parsed_path":[
         "opa",
         "openai",
         "v1",
         "chat",
         "completions"
      ],
      "parsed_query":{
         
      },
      "truncated_body":false,
      "version":[
         [
            {
               "type":"string",
               "value":"encoding"
            },
            {
               "type":"string",
               "value":"protojson"
            }
         ],
         [
            {
               "type":"string",
               "value":"ext_authz"
            },
            {
               "type":"string",
               "value":"v3"
            }
         ]
      ]
   },
   "labels":{
      "id":"d0a69786-8aa9-43cd-808d-2079a3fffb55",
      "version":"1.9.0"
   },
   "level":"info",
   "metrics":{
      "timer_rego_external_resolve_ns":492,
      "timer_rego_query_eval_ns":392669,
      "timer_server_handler_ns":574087
   },
   "msg":"Decision Log",
   "query":"data.authz",
   "result":{
      "allowed":true,
      "has_body":true,
      "has_passthrough_header":true,
      "http_method":"POST",
      "http_path":"/opa/openai/v1/chat/completions",
      "is_allowed_model":true,
      "is_correct_path":true,
      "is_development":true,
      "reason":[
         
      ],
      "request_body":{
         "messages":[
            {
               "content":"Hi, this is a hello world test.",
               "role":"user"
            }
         ],
         "model":"gpt-3.5-turbo"
      },
      "request_model":"gpt-3.5-turbo",
      "source_ip":"172.64.150.238"
   },
   "time":"2026-01-05T20:54:47Z",
   "timestamp":"2026-01-05T20:54:47.36661959Z",
   "type":"openpolicyagent.org/decision_logs"
}
```
