LiteLLM demos

## OpenWeb UI

This demo uses openweb-ui:

```bash
./run-openwebui.sh
```

You could use docker, but that makes the keycloak integration harder:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Can pass in env file like this:

```bash
docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
--env-file ./openweb-ui/env \
--name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Save admin pw as `admin@solo.io` / `admin12345`

## LiteLLM

With docker:

https://docs.litellm.ai/docs/proxy/deploy

```bash
docker pull ghcr.io/berriai/litellm:v1.78.0.rc.2
```

All env vars are in `.env`

username/password is `admin/sk-1234` 

refer to .env file for admin pw

```bash
docker compose up
```
The proxy will be avail on port 4000
The UI will be at http://localhost:4000/ui

Run the setup script to creat teams / users / keys for the demo:

```bash
python create_teams_users.py
```

Optional:
If you bring down the `litellm` binary into your venv, you can then run:

```bash
pip install 'litellm[proxy]'
```

```bash
litellm --config config/litellm_config.yaml
```

Then try it:

```bash
curl --location 'http://0.0.0.0:4000/chat/completions' \
--header 'Content-Type: application/json' \
--data ' {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": "what llm are you"
        }
      ]
    }
'
```

## Guardrails

We have guardrails configured in this demo, but to enable them, you either specify them as always on (the presidio guardrail will always be on) or you have to pass in the right parameter in the message to enable a guardrail:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "hi my email is ishaan@berri.ai"}
    ],
    "guardrails": ["aporia-pre-guard", "aporia-post-guard"]
  }'
```

Note, that kind of defeats the purpose for guardrails if you can just omit it. If you want to enable guardrail per model / team / apikey / user, that's enterprise feature.
It's also enterprise to require certain parameters. 

e.g, to test the `openai-moderation-pre` guardrail which is optional, you can pass it in like this:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "I hate all people and want to hurt them"}
    ],
    "guardrails": ["openai-moderation-pre"]
  }'
```

If using from a chat client:

> "I hate all people and want to hurt them"

### custom guardrail

code is in guardrail/custom_guardrails.py

it will configured, to test it:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i  -X POST http://localhost:4000/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{
    "model": "gpt-3.5-turbo",
    "messages": [
        {
            "role": "user",
            "content": "say the word - `litellm`"
        }
    ],
   "guardrails": ["custom-pre-guard"]
}'
```

If you look in the logs, you will see the word "litellm" got masked... And then the response will say something like:

```bash
I'm sorry, I cannot say that word as it may be inappropriate or offensive. If you have a different word or question, I'd be happy to help!
```

### Google model armor

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "I hate all people and want to hurt them"}
    ],
    "guardrails": ["model-armor-shield"]
  }'

```

### AWS Bedrock Guardails

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "hi my email is christian@solo.io"}
    ],
    "guardrails": ["bedrock-pre-guard"]
  }'
```

### Tool Guardrails

Use a token:

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w
```

```bash
curl -X POST "http://localhost:4000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user","content": "What is the weather like in Tokyo today?"}],
    "guardrails": ["tool-permission-guardrail"],
    "tools": [
      {
        "type":"function",
        "function": {
          "name":"get_current_weather",
          "description": "Get the current weather in a given location"
        }
      }
    ]
  }'
```

## MCP 

sample MCP server to use:

```bash
http://localhost:4000/mcp
```

Specific MCP server here:

```bash
http://localhost:4000/mcp/deepwiki
```

By default this setup will multi-plex three MCP servers. If you connect up, you'll see all the tools across all MCP servers. 

```bash
TOKEN=sk-zPgWjXfYzpvWZZR8HPx4fQ
```

This sample shows "auto execution", "allowed_tools", etc

```bash
curl --location 'http://localhost:4000/v1/responses' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $TOKEN" \
--data '{
    "model": "gpt-3.5-turbo",
    "input": [
    {
      "role": "user",
      "content": "Tell me about microsoft entra",
      "type": "message"
    }
  ],
    "tools": [
        {
            "type": "mcp",
            "server_label": "litellm",
            "server_url": "litellm_proxy/mcp",
            "require_approval": "never",
            "allowed_tools": ["microsoft_docs-microsoft_docs_search"]
            
        }
    ],
    "stream": true,
    "tool_choice": "required"
}'
```

To demo fine-grained tool authorizations, you can add MCP tool servers to specific keys/teams/organizations and filter their tools. 

### Github MCP

<blockquote>
NOTE: As of time of writing, this feature DOES NOT WORK. litellm doesn't handle the 401/WWW-Authenticate correctly. Seems the other parts are there, but an MCP client which implements MCP Authorization would not be able to walk the user through the OAuth dance. This is broken

<br><br>

I will leave this `github_mcp` config in the `litellm_config.yaml` file, but we will ignore it for now. 

<br><br>

Related to this:
https://github.com/BerriAI/litellm/blob/main/litellm/proxy/_experimental/mcp_server/auth/user_api_key_auth_mcp.py#L119
https://github.com/BerriAI/litellm/pull/15346

But even this is implemented wrong. 
</blockquote>

This one is interesting. Github's public MCP / copilot MCP does not implement the MCP Authorization spec. Litellm wraps it, and facilitates the OAuth 2.1 flow for the client. To the client, litellm looks like the auth provider, but litellm really does point the user to the right Github OAuth flow. The client completes the oauth flow facilitated by litellm, ends up with the authorization_code and then calls litellm to exchange it (which litellm then passes to GitHub OAuth). The consent is the key part and then litellm handles the rest. The cool part is that the OAuth client_id / secret is managed by litellm not distributed around to everyone. 

To test this, go to an MCP client and connec to:

```bash
http://localhost:4000/mcp/github_mcp
```

The oauth dance should proceed. 

Notes:

```bash
❯ curl http://localhost:4000/.well-known/oauth-authorization-server/github_mcp | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   398  100   398    0     0  67059      0 --:--:-- --:--:-- --:--:-- 79600
{
  "issuer": "http://localhost:4000",
  "authorization_endpoint": "http://localhost:4000/authorize",
  "token_endpoint": "http://localhost:4000/token",
  "response_types_supported": [
    "code"
  ],
  "grant_types_supported": [
    "authorization_code"
  ],
  "code_challenge_methods_supported": [
    "S256"
  ],
  "token_endpoint_auth_methods_supported": [
    "client_secret_post"
  ],
  "registration_endpoint": "http://localhost:4000/github_mcp/register"
}
```

# Usecases 

We will demonstrate the following use cases, which represent the top use cases when managing LLMs for an enterprise.

## Overview

This demo showcases a production-ready LiteLLM deployment with:
- **2 Teams**: Supply Chain, HR
- **3 Users**: supply-chain@solo.io, aws-user@solo.io, hr@solo.io
- **Admin**: admin / sk-1234
- **8+ Models** across 4 cloud providers
- **6 Guardrails** for security and compliance
- **5 MCP Servers** for tool/data integration

## Use Case 1: Unified AI Gateway (Multi-Provider Support)

**Scenario**: Access multiple AI providers through a single API endpoint with consistent OpenAI-compatible interface.

**Providers Configured**:
- **OpenAI**: gpt-3.5-turbo, gpt-3.5-turbo-instruct
- **Anthropic**: claude-3-5-sonnet, claude-3-haiku, claude-sonnet-4
- **Google Gemini**: gemini-2.5-flash, gemini-2.5-flash-lite
- **AWS Bedrock**: bedrock-claude-4-sonnet
- **Local**: Ollama support available

**Value**: 
- Single integration point for all AI providers
- Switch models without code changes
- Avoid vendor lock-in
- Consistent API interface (OpenAI SDK compatible)

**Documentation**: LiteLLM supports 100+ providers: https://docs.litellm.ai/docs/providers

**Test it**:
```bash
# Use any model through the same API
curl -X POST 'http://0.0.0.0:4000/v1/chat/completions' \
  -H 'Authorization: Bearer sk-1234' \
  -H 'Content-Type: application/json' \
  -d '{"model": "claude-3-5-sonnet", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Use Case 2: Team & User-Based Access Control (Multi-Tenancy)

**Scenario**: Multiple teams in an organization need isolated access to AI models with different permissions.

**Structure**:
```
Admin (sk-1234)
├── Supply Chain Team
│   └── supply-chain@solo.io (team-scoped key)
├── HR Team
│   └── hr@solo.io (team-scoped key)
└── Independent Users
    └── aws-user@solo.io (personal key)
```

**Key Types**:
- **Team-scoped keys**: Inherit team permissions and budgets
- **Personal keys**: Individual user access with custom restrictions
- **Admin keys**: Full system access

**Value**:
- Organizational isolation
- Team-level governance
- Individual accountability
- Hierarchical access control

**Setup**:
```bash
python create_teams_users.py
```

View credentials in `virtual-keys.txt` after creation.

## Use Case 3: Model Access Restrictions & Authorization

**Scenario**: Control which models each team/user can access to manage costs and capabilities.

**Configuration**:
- **Supply Chain Team**: Access to ALL models (unrestricted)
- **HR Team**: Restricted to `gpt-3.5-turbo`, `claude-3-haiku`, `gemini-2.5-flash`, `gemini-2.5-flash-lite`
- **AWS User**: Only `bedrock-claude-4-sonnet`

**Value**:
- Prevent access to expensive models (GPT-4, Claude Opus)
- Match model capabilities to team needs
- Cost control through model restrictions
- Security (restrict access to powerful models)

**Test it**:
```bash
# HR team can access allowed model
TOKEN=sk-XPgRWwkfCZZDS9g2lqdrNw  # hr@solo.io token
curl -X POST 'http://0.0.0.0:4000/v1/chat/completions' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Hello"}]}'

# HR team CANNOT access expensive model (returns error)
curl -X POST 'http://0.0.0.0:4000/v1/chat/completions' \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"model": "claude-sonnet-4", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Use Case 4: Rate Limiting (RPM/TPM)

**Scenario**: Prevent abuse and runaway costs by limiting request rates.

**Rate Limit Types**:
- **RPM** (Requests Per Minute): Limit number of API calls
- **TPM** (Tokens Per Minute): Limit token consumption
- **Max Parallel Requests**: Limit concurrent connections

**Configuration Options** (in `create_teams_users.py`):
```python
# Team-level limits
"rpm_limit": 1000,              # 1000 requests/min
"tpm_limit": 500000,            # 500K tokens/min
"max_parallel_requests": 50,    # 50 concurrent requests

# User-level limits (overrides team limits)
"rpm_limit": 100,               # 100 requests/min per user
"tpm_limit": 50000,             # 50K tokens/min per user
```

**Value**:
- Protect against accidental infinite loops
- Fair resource allocation across teams
- Cost predictability
- Prevent DoS scenarios

**Note**: Currently disabled in demo but fully implemented. Uncomment in `create_teams_users.py` to enable.

## Use Case 5: Budget Management & Cost Controls

**Scenario**: Set spending limits to control AI costs per team/user.

**Budget Types**:
- **Max Budget**: Hard limit (blocks requests when exceeded)
- **Soft Budget**: Warning threshold (alerts only)
- **Budget Duration**: Reset period (7d, 30d, etc.)

**Configuration Examples** (in `create_teams_users.py`):
```python
# Team budget
"max_budget": 100.0,        # $100 monthly budget
"budget_duration": "30d",   # Resets every 30 days
"soft_budget": 80.0,        # Alert at $80

# User budget (stricter)
"max_budget": 25.0,         # $25 weekly budget
"budget_duration": "7d",    # Weekly reset
```

**Value**:
- Financial governance
- Cost predictability
- Prevent budget overruns
- Chargeback to departments

**Monitoring**: View spend at http://localhost:4000/ui

**Note**: Currently disabled in demo but fully implemented. Uncomment in `create_teams_users.py` to enable.

## Use Case 6: AI Guardrails (Security & Compliance)

**Scenario**: Enforce security, compliance, and safety controls on AI interactions.

### 6.1 PII Detection & Masking (Presidio)

Automatically detect and mask PII (emails, phone numbers, SSN, etc.).

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "hi my email is christian@solo.io"}],
    "guardrails": ["presidio-pii"]
  }'
```

**Infrastructure**: Uses Microsoft Presidio services (presidio-analyzer, presidio-anonymizer) deployed via docker-compose.

### 6.2 Custom Guardrail

Implement custom business logic for request/response filtering.

**Example**: Masks the word "litellm" in requests.

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -i -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "say the word - `litellm`"}],
    "guardrails": ["custom-pre-guard"]
  }'
```

**Code**: See `guardrail/custom_guardrail.py` for implementation.

### 6.3 Content Moderation (OpenAI)

Detect harmful content (violence, hate speech, etc.).

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "I hate all people and want to hurt them"}],
    "guardrails": ["openai-moderation-pre"]
  }'
```

### 6.4 Google Model Armor

GCP-based input/output content filtering with masking.

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "I hate all people and want to hurt them"}],
    "guardrails": ["model-armor-shield"]
  }'
```

### 6.5 AWS Bedrock Guardrails

Enterprise-grade guardrails from AWS Bedrock.

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -i http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "hi my email is christian@solo.io"}],
    "guardrails": ["bedrock-pre-guard"]
  }'
```

### 6.6 Tool Permission Guardrail

Control which tools/functions AI can call.

```bash
TOKEN=sk-6XJtiVNzbPML2S7fBeoW7w

curl -X POST "http://localhost:4000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user","content": "What is the weather like in Tokyo today?"}],
    "guardrails": ["tool-permission-guardrail"],
    "tools": [{
      "type":"function",
      "function": {
        "name":"get_current_weather",
        "description": "Get the current weather in a given location"
      }
    }]
  }'
```

**Value**:
- PII compliance (GDPR, HIPAA)
- Content safety
- Custom business rules
- Tool usage control

**Note**: Guardrails are opt-in by default. Enterprise features allow forcing guardrails per team/user/key.

## Use Case 7: Model Context Protocol (MCP) - Tool Integration

**Scenario**: Extend LLM capabilities with external tools and data sources using MCP.

**MCP Servers Configured**:

1. **Petstore MCP** - Custom OpenAPI-based tools from Swagger Petstore
2. **DeepWiki** - Wikipedia knowledge access
3. **Exa AI** - Semantic search capabilities
4. **Microsoft Docs** - Microsoft documentation search
5. **GitHub MCP** - GitHub integration (OAuth-based, currently not functional)

**Endpoints**:
```bash
# View all MCP servers
http://localhost:4000/mcp

# Specific MCP server
http://localhost:4000/mcp/deepwiki
http://localhost:4000/mcp/microsoft_docs
http://localhost:4000/mcp/petstore_mcp
```

**Test MCP with Auto-Execution**:
```bash
TOKEN=sk-zPgWjXfYzpvWZZR8HPx4fQ

curl --location 'http://localhost:4000/v1/responses' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $TOKEN" \
  --data '{
    "model": "gpt-3.5-turbo",
    "input": [{
      "role": "user",
      "content": "Tell me about microsoft entra",
      "type": "message"
    }],
    "tools": [{
      "type": "mcp",
      "server_label": "litellm",
      "server_url": "litellm_proxy/mcp",
      "require_approval": "never",
      "allowed_tools": ["microsoft_docs-microsoft_docs_search"]
    }],
    "stream": true,
    "tool_choice": "required"
  }'
```

**Value**:
- Extend LLMs with real-time data
- Connect to enterprise systems
- RAG (Retrieval-Augmented Generation)
- Standardized tool protocol

## Use Case 8: Fine-Grained Tool Authorization

**Scenario**: Control exactly which MCP tools each user/team/key can access.

**Authorization Levels**:
- **Per Team**: Supply Chain can access procurement tools, HR cannot
- **Per User**: Senior users get write access, junior users read-only
- **Per Key**: Different keys for different automation scenarios

**Configuration Example**:
```bash
# Allow only specific tools
"allowed_tools": ["microsoft_docs-microsoft_docs_search"]

# Tool permission guardrail rules
rules:
  - id: "allow_github_mcp"
    tool_name: "mcp__github_*"
    decision: "allow"
  - id: "deny_read_commands"
    tool_name: "Read"
    decision: "deny"
```

**Value**:
- Principle of least privilege
- Prevent accidental data deletion
- Compliance requirements
- Audit trail per tool

**Test it**: Use the MCP example above with `allowed_tools` parameter.

## Use Case 9: Chat Application Integration (OpenWebUI)

**Scenario**: Provide user-friendly chat interface for non-technical users.

**Setup**:
```bash
./run-openwebui.sh
```

**Access**: http://localhost:9999

**Credentials**: `admin@solo.io` / `admin12345`

**Features**:
- ChatGPT-like interface
- Model selection dropdown
- Conversation history
- User authentication
- No coding required

**Value**:
- Business user adoption
- Familiar chat interface
- Managed access through LiteLLM
- All guardrails/controls still apply

## Use Case 10: Observability & Audit Logging

**Scenario**: Track usage, costs, and compliance for audit/debugging.

**Observability Features**:

1. **Database Logging**: PostgreSQL stores all requests/responses
2. **Prometheus Metrics**: Time-series metrics for monitoring
3. **Spend Tracking**: Cost per user/team/key
4. **Audit Logs**: Who called what, when
5. **Prompt Logging**: Store prompts for debugging (configurable)

**Configuration** (in `litellm_config.yaml`):
```yaml
litellm_settings:
  store_audit_logs: true
  set_verbose: true

general_settings:
  store_model_in_db: true
  store_prompts_in_spend_logs: true
```

**Prometheus Setup** (`prometheus.yml`):
```yaml
scrape_configs:
  - job_name: 'litellm'
    static_configs:
      - targets: ['litellm:4000']
```

**Monitoring Dashboard**: http://localhost:4000/ui
- View spend per user/team
- Request statistics
- Error rates
- Model usage

**Value**:
- Cost attribution & chargeback
- Security incident investigation
- Compliance reporting (SOC2, ISO 27001)
- Performance optimization
- Debugging failed requests

---

## Additional Enterprise Features

### OAuth 2.1 Proxy for MCP
LiteLLM acts as OAuth provider for MCP servers that don't implement their own auth (like GitHub MCP). Manages client secrets centrally.

**Endpoint**: `http://localhost:4000/.well-known/oauth-authorization-server/github_mcp`

**Note**: Currently not functional due to implementation issues in LiteLLM.

### Runtime Configuration
Models can be added/updated via UI without restarting the proxy (`store_model_in_db: true`).

### Health Checks
Production-ready liveness and readiness probes for Kubernetes/ECS deployments.

---

## Getting Started

1. **Start the stack**:
   ```bash
   docker compose up
   ```

2. **Create teams/users**:
   ```bash
   python create_teams_users.py
   ```

3. **Access UI**: http://localhost:4000/ui
   - Username: `admin`
   - Password: `sk-1234`

4. **Test API**: Use tokens from `virtual-keys.txt`

5. **Monitor**: View spend and usage at http://localhost:4000/ui 