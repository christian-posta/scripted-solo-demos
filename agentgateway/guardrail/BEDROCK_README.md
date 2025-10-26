# Amazon Bedrock Guardrails Service

A Flask-based guardrail service that integrates with Amazon Bedrock Guardrails to provide comprehensive security for AI applications.

## Features

- **Request Validation**: Screens user prompts before they reach the LLM
- **Response Validation**: Screens LLM responses before they reach the client
- **Multiple Policy Types**:
  - Topic Policy (restricted topics/denied topics)
  - Content Policy (hate speech, insults, violence, sexual content)
  - Word Policy (custom word lists and managed profanity filters)
  - Sensitive Information Policy (PII detection with masking)
  - Contextual Grounding Policy (hallucination detection)
- **Configurable Blocking Modes**: Strict, balanced, or audit mode
- **PII Masking**: Automatic anonymization of detected PII (email, SSN, phone, etc.)
- **Comprehensive Logging**: Detailed logs for debugging and compliance
- **AWS Authentication**: Supports multiple AWS authentication methods

## Prerequisites

- Python 3.8+
- AWS Account with Bedrock Guardrails enabled
- Bedrock Guardrail created and configured
- AWS credentials (IAM role, access keys, or AWS profile)
- Permissions: `bedrock:ApplyGuardrail`

## Installation

```bash
pip install -r requirements.txt
```

Required dependencies:
- `boto3>=1.28.0` - AWS SDK for Python
- `botocore>=1.31.0` - AWS core library
- `Flask>=3.0.0` - Web framework
- `requests>=2.31.0` - HTTP library

## Configuration

### Alignment with LiteLLM

This implementation uses the same configuration parameters as LiteLLM's Bedrock Guardrails integration:

**LiteLLM Config:**
```yaml
- guardrail_name: "bedrock-pre-guard"
  litellm_params:
    guardrail: bedrock
    mode: "pre_call"
    guardrailIdentifier: v1qto5owq7gz  # → BEDROCK_GUARDRAIL_ID
    guardrailVersion: "DRAFT"          # → BEDROCK_GUARDRAIL_VERSION
```

**This Service Config:**
```bash
export BEDROCK_GUARDRAIL_ID=v1qto5owq7gz     # Same as guardrailIdentifier
export BEDROCK_GUARDRAIL_VERSION=DRAFT       # Same as guardrailVersion
```

This means you can use the **same guardrail** for both LiteLLM and this standalone service!

### Environment Variables

Set the following environment variables:

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `BEDROCK_GUARDRAIL_ID` | Guardrail identifier (same as litellm's `guardrailIdentifier`) | `v1qto5owq7gz` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `BEDROCK_GUARDRAIL_VERSION` | Guardrail version (same as litellm's `guardrailVersion`) | `DRAFT` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `BEDROCK_GUARDRAIL_ENABLED` | Enable/disable Bedrock | `true` |
| `BEDROCK_MASK_REQUESTS` | Mask PII in requests | `true` |
| `BEDROCK_MASK_RESPONSES` | Mask PII in responses | `true` |
| `BEDROCK_BLOCKING_MODE` | Blocking mode | `strict` |
| `BEDROCK_FAIL_ON_ERROR` | Fail on API errors | `false` |

### AWS Authentication

Bedrock supports multiple authentication methods (in order of precedence):

#### 1. **Environment Variables** (recommended for containers)
```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_SESSION_TOKEN=optional-session-token  # For temporary credentials
```

#### 2. **AWS Profile** (recommended for local development)
```bash
export AWS_PROFILE=my-profile  # Uses ~/.aws/credentials
```

#### 3. **IAM Role** (recommended for ECS/EKS)
- Automatically detected when running on EC2, ECS, EKS, or Lambda
- No configuration needed - boto3 handles it automatically

#### 4. **Explicit Credentials** (via custom environment variables)
```bash
# Service will pass these to boto3.Session()
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### Blocking Modes

- **`strict`** (default): Block ANY violation including anonymized PII
- **`balanced`**: Block serious violations (content, topic, words) but allow PII with masking
- **`audit`**: Never block, only log violations (useful for testing)

## Usage

### Start the Service

```bash
# Set required configuration (use your guardrail ID from litellm config)
export BEDROCK_GUARDRAIL_ID=v1qto5owq7gz  # Your guardrailIdentifier
export BEDROCK_GUARDRAIL_VERSION=DRAFT     # Your guardrailVersion (optional, defaults to DRAFT)
export AWS_REGION=us-east-1

# Start the service
python bedrock_guardrail.py
```

**Note:** Use the same `guardrailIdentifier` from your LiteLLM configuration!

The service runs on `http://127.0.0.1:7273` by default (note: different port from Model Armor on 7272).

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
    "reason": "No violations detected by Bedrock Guardrails"
  }
}
```

Response (blocked):
```json
{
  "action": {
    "body": "Request rejected by Bedrock Guardrails: BLOCKED: Content policy: violence",
    "status_code": 403,
    "reason": "BLOCKED: Content policy: violence"
  }
}
```

Response (masked PII):
```json
{
  "action": {
    "body": {
      "messages": [
        {
          "role": "user",
          "content": "My email is {EMAIL} and phone is {US_PHONE}"
        }
      ]
    },
    "reason": "Content sanitized by Bedrock Guardrails"
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

## Bedrock Guardrail Configuration

### Creating a Guardrail

Use AWS Console or CLI to create a guardrail:

```bash
aws bedrock create-guardrail \
  --name my-guardrail \
  --description "Guardrail for AI applications" \
  --blocked-input-messaging "Your request was blocked due to policy violations" \
  --blocked-outputs-messaging "The response was blocked due to policy violations" \
  --region us-east-1
```

### Configuring Policies

#### 1. **Topic Policy**
Define topics to block or allow:
```bash
aws bedrock update-guardrail \
  --guardrail-identifier abc123 \
  --topic-policy-config '{
    "topicsConfig": [{
      "name": "Financial Advice",
      "definition": "Requests for investment or financial recommendations",
      "type": "DENY"
    }]
  }'
```

#### 2. **Content Policy**
Filter harmful content:
- Hate speech
- Insults
- Sexual content
- Violence
- Misconduct

Each can be set to filter at: NONE, LOW, MEDIUM, or HIGH threshold

#### 3. **Word Policy**
Block specific words:
```bash
# Custom word list
--word-policy-config '{
  "wordsConfig": [{
    "text": "badword"
  }],
  "managedWordListsConfig": [{
    "type": "PROFANITY"
  }]
}'
```

#### 4. **Sensitive Information Policy**
Detect and mask PII:
- EMAIL
- PHONE
- NAME
- ADDRESS
- SSN
- CREDIT_CARD
- And more...

Action can be: `BLOCK` or `ANONYMIZE`

#### 5. **Contextual Grounding Policy**
Check if model outputs are grounded in provided context (helps prevent hallucinations).

## Logging

The service provides comprehensive logging at multiple levels:

### INFO Level
- Initialization status
- Request/response validation events
- Successful passes
- PII masking notifications
- Usage metrics

### WARNING Level
- Blocked requests/responses with violation details
- Individual policy violations

### ERROR Level
- API errors with stack traces
- Authentication failures
- Configuration errors

### DEBUG Level
- Raw API requests/responses
- AWS SigV4 signing details
- Detailed policy analysis

## Example Log Output

```
2025-10-26 12:00:00 - __main__ - INFO - Initializing Bedrock Guardrail client: guardrail=abc123, version=DRAFT, region=us-east-1
2025-10-26 12:00:00 - __main__ - INFO - AWS credentials loaded successfully
2025-10-26 12:00:00 - __main__ - INFO - Bedrock Guardrails client initialized successfully
2025-10-26 12:00:05 - __main__ - INFO - Validating user prompt with Bedrock Guardrails (1 messages)
2025-10-26 12:00:06 - __main__ - INFO - Bedrock input result: action=GUARDRAIL_INTERVENED
2025-10-26 12:00:06 - __main__ - INFO - PII detected (anonymized): EMAIL
2025-10-26 12:00:06 - __main__ - INFO - Violations detected: ['pii:EMAIL']
2025-10-26 12:00:06 - __main__ - INFO - REQUEST CONTENT MASKED by Bedrock Guardrails
```

## Error Handling

The service includes robust error handling:

1. **Missing Guardrail ID**: Logs error and disables service (or fails based on `BEDROCK_FAIL_ON_ERROR`)
2. **AWS Credential Errors**: Detailed logging of authentication issues
3. **API Errors**: Logs HTTP status codes and response bodies
4. **Network Errors**: Handles timeouts and connection failures
5. **Fallback Behavior**: If `BEDROCK_FAIL_ON_ERROR=false`, errors result in pass-through

## Testing

### Run Test Suite
```bash
python test_bedrock_guardrail.py
```

### Test Manually

Safe content:
```bash
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "messages": [{"role": "user", "content": "What is AI?"}]
    }
  }'
```

Content with PII:
```bash
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "messages": [{"role": "user", "content": "My email is john@example.com"}]
    }
  }'
```

### Test Different Modes

```bash
# Balanced mode (allows masked PII)
export BEDROCK_BLOCKING_MODE=balanced
python bedrock_guardrail.py

# Audit mode (logs only)
export BEDROCK_BLOCKING_MODE=audit
python bedrock_guardrail.py
```

## Troubleshooting

### "BEDROCK_GUARDRAIL_ID is required"
- Set the environment variable: `export BEDROCK_GUARDRAIL_ID=your-id`
- Get your guardrail ID from AWS Console or CLI

### "Failed to load AWS credentials"
- Check AWS credentials are configured
- Verify IAM permissions include `bedrock:ApplyGuardrail`
- Test with: `aws sts get-caller-identity`

### "Bedrock API returned 403"
- Verify Bedrock is enabled in your region
- Check IAM policy includes Bedrock permissions
- Ensure guardrail ID exists and is in correct region

### "Bedrock API returned 404"
- Guardrail ID may be incorrect
- Guardrail may not exist in specified region
- Check guardrail version (DRAFT vs version number)

### No Violations Detected
- Check guardrail policies are configured
- Verify content should actually trigger policies
- Enable DEBUG logging to see raw API responses

## AWS IAM Policy Example

Minimum required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:ApplyGuardrail"
      ],
      "Resource": [
        "arn:aws:bedrock:us-east-1:123456789:guardrail/your-guardrail-id"
      ]
    }
  ]
}
```

## Cost Considerations

Bedrock Guardrails charges based on:
- **Input units**: Content evaluated from user prompts
- **Output units**: Content evaluated from model responses
- Different rates for different policy types

Each text unit is ~1000 characters. Monitor usage via CloudWatch or the `usage` field in logs.

## Integration with Agent Gateway

This guardrail service is designed to work with Agent Gateway and uses the **same guardrail** as LiteLLM.

### Standalone Usage
Route requests through this service before reaching the LLM:
- **Request endpoint**: `http://127.0.0.1:7273/request`
- **Response endpoint**: `http://127.0.0.1:7273/response`

### Alongside LiteLLM
You can use this service for **custom guardrail logic** while LiteLLM uses the same Bedrock guardrail:

```yaml
# Agent Gateway config
guardrails:
  # Your custom guardrail service
  - name: bedrock-custom
    endpoint: http://127.0.0.1:7273
    
  # LiteLLM with same guardrail
  - guardrail_name: "bedrock-pre-guard"
    litellm_params:
      guardrail: bedrock
      guardrailIdentifier: v1qto5owq7gz  # Same guardrail!
      guardrailVersion: "DRAFT"
```

**Benefits:**
- Both use the same Bedrock guardrail configuration
- Consistent policy enforcement
- This service adds custom blocking modes and enhanced logging
- LiteLLM provides native integration with Bedrock models

## Comparison: Bedrock vs Model Armor

| Feature | Bedrock Guardrails | Google Model Armor |
|---------|-------------------|-------------------|
| Port | 7273 | 7272 |
| Authentication | AWS SigV4 | Google Bearer Token |
| PII Masking | ✅ Excellent | ✅ Good |
| Topic Filtering | ✅ Yes | ❌ No |
| Content Filtering | ✅ Yes | ✅ Yes (RAI) |
| Word Lists | ✅ Yes | ❌ No |
| Hallucination Detection | ✅ Yes (grounding) | ❌ No |
| Configuration | AWS Console/CLI | GCP Console/gcloud |

## Production Deployment

For production:
1. Use a production WSGI server (gunicorn, uwsgi)
2. Use versioned guardrails (not DRAFT)
3. Configure appropriate blocking mode
4. Set up monitoring/alerting
5. Use IAM roles instead of access keys
6. Configure `BEDROCK_FAIL_ON_ERROR` appropriately

Example with gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:7273 bedrock_guardrail:app
```

## Support

For issues:
- Check AWS Bedrock Guardrails documentation
- Review logs for detailed error messages
- Verify guardrail configuration in AWS Console
- Test with `test_bedrock_guardrail.py` script

## License

See parent project LICENSE

