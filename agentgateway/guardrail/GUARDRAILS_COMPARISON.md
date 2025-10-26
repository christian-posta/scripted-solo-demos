# Guardrails Implementation Comparison

This document compares the two guardrail implementations: Google Model Armor and Amazon Bedrock Guardrails.

## Quick Reference

| Feature | Google Model Armor | Amazon Bedrock Guardrails |
|---------|-------------------|---------------------------|
| **File** | `modelarmor_guardrail.py` | `bedrock_guardrail.py` |
| **Port** | 7272 | 7273 |
| **Test Script** | `test_guardrail.py` | `test_bedrock_guardrail.py` |
| **Documentation** | `README.md` | `BEDROCK_README.md` |

## Authentication

### Google Model Armor
```bash
# Service Account JSON file
export MODEL_ARMOR_CREDENTIALS=/path/to/credentials.json

# Simple Bearer token authentication
# Automatic token refresh via google-auth
```

**Pros:**
- Simple authentication flow
- Easy to set up for development
- Automatic credential refresh

**Cons:**
- Requires service account JSON file
- Need to manage file security

### Amazon Bedrock Guardrails
```bash
# Multiple authentication options:

# 1. Environment variables
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# 2. AWS Profile
export AWS_PROFILE=my-profile

# 3. IAM Role (ECS/EKS) - automatic
# No configuration needed
```

**Pros:**
- Multiple authentication methods
- Native AWS integration (IAM roles)
- Works seamlessly in AWS environments

**Cons:**
- More complex (requires AWS SigV4 signing)
- Requires boto3 library

## Dependencies

### Model Armor
```
google-auth>=2.0.0
google-auth-oauthlib>=0.4.0
requests>=2.31.0
```
**Total:** 3 additional packages

### Bedrock
```
boto3>=1.28.0
botocore>=1.31.0
requests>=2.31.0
```
**Total:** 3 additional packages (but boto3 brings more deps)

## Configuration

### Model Armor Environment Variables
```bash
MODEL_ARMOR_ENABLED=true
MODEL_ARMOR_PROJECT_ID=your-project-id
MODEL_ARMOR_LOCATION=us-central1
MODEL_ARMOR_TEMPLATE_ID=your-template
MODEL_ARMOR_CREDENTIALS=/path/to/credentials.json
MODEL_ARMOR_MASK_REQUESTS=true
MODEL_ARMOR_MASK_RESPONSES=true
MODEL_ARMOR_BLOCKING_MODE=strict
MODEL_ARMOR_FAIL_ON_ERROR=false
```

### Bedrock Environment Variables
```bash
BEDROCK_GUARDRAIL_ENABLED=true
BEDROCK_GUARDRAIL_ID=your-guardrail-id
BEDROCK_GUARDRAIL_VERSION=DRAFT
AWS_REGION=us-east-1
# AWS credentials (multiple options)
BEDROCK_MASK_REQUESTS=true
BEDROCK_MASK_RESPONSES=true
BEDROCK_BLOCKING_MODE=strict
BEDROCK_FAIL_ON_ERROR=false
```

**Note:** Both follow similar configuration patterns for consistency.

## Policy Types and Detection

### Google Model Armor
1. **RAI (Responsible AI)** - Content safety (dangerous, sexual, hate, harassment)
2. **PI/Jailbreak** - Prompt injection and jailbreak attempts
3. **Malicious URI** - Dangerous URLs
4. **CSAM** - Child safety content
5. **SDP (Sensitive Data Protection)** - PII detection and masking
6. **Virus Scan** - File malware detection

**Total:** 6 policy types

### Amazon Bedrock Guardrails
1. **Topic Policy** - Restricted/denied topics
2. **Content Policy** - Hate, insults, sexual, violence, misconduct
3. **Word Policy** - Custom words + managed profanity lists
4. **Sensitive Information Policy** - PII with masking (EMAIL, SSN, PHONE, etc.)
5. **Contextual Grounding Policy** - Hallucination detection

**Total:** 5 policy types

## Blocking vs Masking

### Model Armor
- **`filterMatchState`**: `MATCH_FOUND` or `NO_MATCH_FOUND`
- **Blocking**: Any filter match in strict mode
- **Masking**: Via SDP `deidentifyResult`
- **Actions**: No explicit action field per filter

### Bedrock
- **`action`**: `NONE` or `GUARDRAIL_INTERVENED`
- **Blocking**: Explicit `BLOCKED` action
- **Masking**: Explicit `ANONYMIZED` action with clear distinction
- **Actions**: Each violation has action: `BLOCKED`, `ANONYMIZED`, or none

**Winner:** Bedrock has clearer action semantics

## PII Masking Quality

### Model Armor
```
Original: "My email is john@example.com"
Masked:   "My email is [REDACTED]"
```
Simple redaction with generic placeholder.

### Bedrock
```
Original: "My email is john@example.com and SSN is 123-45-6789"
Masked:   "My email is {EMAIL} and SSN is {US_SOCIAL_SECURITY_NUMBER}"
```
Type-specific placeholders show what was masked.

**Winner:** Bedrock (more informative masking)

## Response Format

### Model Armor
```json
{
  "sanitizationResult": {
    "filterMatchState": "MATCH_FOUND",
    "filterResults": {
      "rai": { "raiFilterResult": {...} },
      "sdp": { "sdpFilterResult": {...} }
    }
  }
}
```

### Bedrock
```json
{
  "action": "GUARDRAIL_INTERVENED",
  "outputs": [{"text": "masked content"}],
  "assessments": [{
    "topicPolicy": {...},
    "contentPolicy": {...},
    "wordPolicy": {...},
    "sensitiveInformationPolicy": {...}
  }],
  "usage": {...}
}
```

**Winner:** Bedrock (clearer structure, includes usage metrics)

## Performance Considerations

### Model Armor
- **Endpoint**: Global (with regional options)
- **Latency**: ~300-600ms typical
- **Timeout**: 10 seconds
- **No reported throttling limits**

### Bedrock
- **Endpoint**: Regional
- **Latency**: ~200-500ms typical
- **Timeout**: 30 seconds
- **Throttling**: Standard AWS API limits (can be increased)

**Winner:** Roughly equal, depends on proximity to regions

## Cost Model

### Model Armor
- Pricing not publicly detailed (contact Google)
- Likely based on API calls and processing units
- Part of Google Cloud AI services

### Bedrock
- **Public pricing** per 1000 text units (characters)
- Different rates for input vs output
- Different rates per policy type
- Detailed usage metrics in response

**Winner:** Bedrock (transparent pricing)

## Ease of Setup

### Model Armor
1. ✅ Create GCP project
2. ✅ Enable Model Armor API
3. ✅ Create template via gcloud
4. ✅ Create service account
5. ✅ Download credentials JSON
6. ✅ Configure template filters

**Steps:** 6 steps

### Bedrock
1. ✅ Enable Bedrock in AWS account
2. ✅ Create guardrail via Console/CLI
3. ✅ Configure policies
4. ✅ Set AWS credentials (IAM role or keys)

**Steps:** 4 steps

**Winner:** Bedrock (simpler, especially with IAM roles)

## Integration Complexity

### Model Armor
```python
# Simple HTTP POST with Bearer token
headers = {'Authorization': f'Bearer {token}'}
response = requests.post(url, headers=headers, json=body)
```

### Bedrock
```python
# Requires AWS SigV4 signing
aws_request = AWSRequest(method='POST', url=url, data=body)
signer = SigV4Auth(credentials, 'bedrock', region)
signer.add_auth(aws_request)
response = requests.post(url, headers=aws_request.headers, data=body)
```

**Winner:** Model Armor (simpler HTTP calls)

## Use Case Recommendations

### Choose Google Model Armor if:
- ✅ Already using Google Cloud Platform
- ✅ Need jailbreak/prompt injection detection
- ✅ Want malicious URI scanning
- ✅ Prefer simpler authentication
- ✅ Need CSAM detection
- ✅ Want virus scanning for files

### Choose Amazon Bedrock if:
- ✅ Already using AWS
- ✅ Need topic-based filtering
- ✅ Want custom word lists
- ✅ Need hallucination detection (grounding)
- ✅ Prefer transparent pricing
- ✅ Better PII masking needed
- ✅ Want managed profanity filters

## Code Structure Comparison

Both implementations follow the same Flask structure:

```
1. Configuration via environment variables
2. Client class with authentication
3. API call methods (input and output)
4. Result processing and decision logic
5. Flask endpoints (/request and /response)
6. Consistent logging throughout
```

**Similarity:** ~90% - Easy to switch between them!

## Running Both Services

### Different Ports
- Model Armor: `127.0.0.1:7272`
- Bedrock: `127.0.0.1:7273`

You can run **both simultaneously** and route different traffic to each!

### Hybrid Approach
```python
# Route to Model Armor for jailbreak detection
if needs_jailbreak_check:
    response = requests.post('http://localhost:7272/request', ...)

# Route to Bedrock for PII masking
if needs_pii_masking:
    response = requests.post('http://localhost:7273/request', ...)
```

## Testing

### Model Armor Tests
```bash
python test_guardrail.py
```
- 7 test cases
- Tests PII, jailbreak, safe content
- Credit card test reliably triggers RAI filter

### Bedrock Tests
```bash
python test_bedrock_guardrail.py
```
- 9 test cases
- Tests multiple PII types, harmful content
- More comprehensive PII testing

## Migration Path

### From Model Armor to Bedrock
1. Map Model Armor template filters to Bedrock policies
2. Update environment variables
3. Change service port if needed
4. Test with `test_bedrock_guardrail.py`

### From Bedrock to Model Armor
1. Map Bedrock policies to Model Armor template
2. Create GCP service account
3. Update environment variables
4. Test with `test_guardrail.py`

**Migration difficulty:** Low - similar API patterns

## Production Checklist

### Model Armor
- [ ] Use production GCP project
- [ ] Restrict service account permissions
- [ ] Use versioned template (not ad-hoc)
- [ ] Enable DEBUG logging initially
- [ ] Monitor API quotas
- [ ] Set up alerting for blocked requests
- [ ] Use gunicorn for production serving

### Bedrock
- [ ] Use versioned guardrail (not DRAFT)
- [ ] Use IAM roles instead of access keys
- [ ] Enable CloudWatch logging
- [ ] Monitor usage/costs
- [ ] Set up alerting for blocked requests
- [ ] Configure appropriate timeout
- [ ] Use gunicorn for production serving

## Summary

| Criterion | Winner | Reason |
|-----------|--------|--------|
| **Setup Ease** | Bedrock | Fewer steps, native AWS integration |
| **Authentication** | Model Armor | Simpler implementation |
| **PII Masking** | Bedrock | Better placeholders, clearer actions |
| **Policy Variety** | Model Armor | More policy types (6 vs 5) |
| **Cost Transparency** | Bedrock | Public pricing |
| **API Clarity** | Bedrock | Clearer response structure |
| **Special Features** | Tie | MA: jailbreak, CSAM; BR: topics, grounding |
| **Documentation** | Bedrock | More detailed AWS docs |

## Recommendation

**For most use cases:** Choose based on your cloud provider:
- **On AWS?** → Use Bedrock Guardrails
- **On GCP?** → Use Model Armor
- **Multi-cloud?** → Use Bedrock (more mature, better documented)
- **Need jailbreak detection?** → Use Model Armor
- **Need hallucination detection?** → Use Bedrock

**Best practice:** Implement both and use them for different purposes:
- Model Armor: Security (jailbreak, malicious content)
- Bedrock: Compliance (PII, content policies, topics)

## Files Created

### Model Armor
- `modelarmor_guardrail.py` (545 lines)
- `test_guardrail.py` (157 lines)
- `README.md` (250 lines)
- `IMPLEMENTATION_NOTES.md` (193 lines)
- `TEST_RESULTS.md` (218 lines)

### Bedrock
- `bedrock_guardrail.py` (620 lines)
- `test_bedrock_guardrail.py` (168 lines)
- `BEDROCK_README.md` (428 lines)

### Comparison
- `GUARDRAILS_COMPARISON.md` (this file)

**Total:** 2,579 lines of code and documentation! 🎉

