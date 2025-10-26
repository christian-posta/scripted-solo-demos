# Model Armor Guardrail Service

A Flask-based guardrail service that integrates with Google Cloud Model Armor to provide comprehensive security for AI applications.

## Features

- **Request Validation**: Screens user prompts before they reach the LLM
- **Response Validation**: Screens LLM responses before they reach the client
- **Multiple Security Filters**:
  - RAI (Responsible AI) policy violations
  - Prompt injection & jailbreak attempts
  - Malicious URI detection
  - CSAM (Child Safety) content
  - PII/Sensitive data detection with masking
- **Configurable Blocking Modes**: Strict, balanced, or audit mode
- **Comprehensive Logging**: Detailed logs for debugging and compliance

## Prerequisites

- Python 3.8+
- Google Cloud Project with Model Armor enabled
- Service account credentials with Model Armor permissions
- Model Armor template configured in your GCP project

## Installation

```bash
pip install -r requirements.txt
```

## Configuration

Set the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `MODEL_ARMOR_ENABLED` | Enable/disable Model Armor | `true` |
| `MODEL_ARMOR_PROJECT_ID` | GCP Project ID | `ceposta-solo-testing` |
| `MODEL_ARMOR_LOCATION` | GCP Location/Region | `us-central1` |
| `MODEL_ARMOR_TEMPLATE_ID` | Model Armor Template ID | `litellm-guardrail` |
| `MODEL_ARMOR_CREDENTIALS` | Path to service account JSON | `/app/credentials.json` |
| `MODEL_ARMOR_MASK_REQUESTS` | Mask PII in requests | `true` |
| `MODEL_ARMOR_MASK_RESPONSES` | Mask PII in responses | `true` |
| `MODEL_ARMOR_BLOCKING_MODE` | Blocking mode (strict/balanced/audit) | `strict` |
| `MODEL_ARMOR_FAIL_ON_ERROR` | Fail on API errors | `false` |

### Blocking Modes

- **`strict`** (default): Block on ANY violation including PII
- **`balanced`**: Block only on serious violations (RAI, jailbreak, malicious URI, CSAM) but allow PII with masking
- **`audit`**: Never block, only log violations (useful for testing)

## Usage

### Start the Service

```bash
python modelarmor_guardrail.py
```

The service runs on `http://127.0.0.1:7272` by default.

### API Endpoints

#### `/request` - Validate User Prompts

**POST** `/request`

Request body:
```json
{
  "body": {
    "messages": [
      {
        "role": "user",
        "content": "User's prompt text"
      }
    ]
  }
}
```

Response (passed):
```json
{
  "action": {
    "reason": "No violations detected by Model Armor"
  }
}
```

Response (blocked):
```json
{
  "action": {
    "body": "Request rejected by Model Armor: BLOCKED: Prompt injection/jailbreak attempt",
    "status_code": 403,
    "reason": "BLOCKED: Prompt injection/jailbreak attempt"
  }
}
```

Response (masked):
```json
{
  "action": {
    "body": {
      "messages": [
        {
          "role": "user",
          "content": "Sanitized content with [REDACTED] PII"
        }
      ]
    },
    "reason": "Content sanitized by Model Armor"
  }
}
```

#### `/response` - Validate LLM Responses

**POST** `/response`

Request body:
```json
{
  "body": {
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "LLM's response text"
        }
      }
    ]
  }
}
```

Response format is similar to `/request` endpoint.

## Logging

The service provides comprehensive logging at multiple levels:

### INFO Level
- Initialization status
- Request/response validation events
- Successful passes
- Content masking notifications

### WARNING Level
- Blocked requests/responses with violation details
- Individual filter violations (RAI, jailbreak, etc.)

### ERROR Level
- API errors with stack traces
- Authentication failures
- Configuration errors

### DEBUG Level
- Raw API requests/responses
- Token refresh events
- Detailed filter analysis

## Example Log Output

```
2025-10-26 12:00:00 - __main__ - INFO - Initializing Model Armor client: project=ceposta-solo-testing, location=us-central1, template=litellm-guardrail
2025-10-26 12:00:00 - __main__ - INFO - Model Armor credentials loaded successfully
2025-10-26 12:00:00 - __main__ - INFO - Model Armor client initialized successfully
2025-10-26 12:00:05 - __main__ - INFO - Validating user prompt with Model Armor (role=user)
2025-10-26 12:00:06 - __main__ - INFO - Model Armor user_prompt result: filterMatchState=MATCH_FOUND
2025-10-26 12:00:06 - __main__ - INFO - SDP PII detected: 2 findings
2025-10-26 12:00:06 - __main__ - INFO - Violations detected: ['pii'], blocking_mode=strict, should_block=True
2025-10-26 12:00:06 - __main__ - WARNING - REQUEST BLOCKED by Model Armor: BLOCKED: PII/sensitive data detected
```

## Error Handling

The service includes robust error handling:

1. **Credential Errors**: Logs detailed error messages if credentials are missing or invalid
2. **API Errors**: Logs HTTP status codes and response bodies for debugging
3. **Network Errors**: Handles timeouts and connection failures
4. **Fallback Behavior**: If `MODEL_ARMOR_FAIL_ON_ERROR=false`, errors result in pass-through (with logging)

## Testing

### Test with Safe Content
```bash
curl -X POST http://127.0.0.1:7272/request \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "messages": [
        {"role": "user", "content": "What is the weather today?"}
      ]
    }
  }'
```

### Test with PII Content
```bash
curl -X POST http://127.0.0.1:7272/request \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "messages": [
        {"role": "user", "content": "My email is test@example.com and my SSN is 123-45-6789"}
      ]
    }
  }'
```

### Test with Audit Mode
```bash
export MODEL_ARMOR_BLOCKING_MODE=audit
python modelarmor_guardrail.py
# Now all requests pass through but violations are logged
```

## Troubleshooting

### "Credentials file not found"
- Ensure `MODEL_ARMOR_CREDENTIALS` path is correct
- Verify the file exists and is readable

### "Model Armor API returned 401"
- Service account credentials may be expired or invalid
- Check service account has necessary permissions

### "Model Armor API returned 404"
- Verify `MODEL_ARMOR_TEMPLATE_ID` exists in your project
- Check `MODEL_ARMOR_PROJECT_ID` and `MODEL_ARMOR_LOCATION` are correct

### No blocking occurs in strict mode
- Check `MODEL_ARMOR_ENABLED=true`
- Verify Model Armor template filters are configured
- Enable DEBUG logging to see raw API responses

## Integration with Agent Gateway

This guardrail service is designed to work with Agent Gateway. Configure Agent Gateway to route requests through this service before reaching the LLM.

## License

See parent project LICENSE

