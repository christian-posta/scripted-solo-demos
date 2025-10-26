# Quick Start - Bedrock Guardrails with Your Configuration

This guide shows how to use Bedrock Guardrails with your existing LiteLLM configuration.

## Your LiteLLM Configuration

You're currently using:
```yaml
- guardrail_name: "bedrock-pre-guard"
  litellm_params:
    guardrail: bedrock
    mode: "pre_call"
    guardrailIdentifier: v1qto5owq7gz
    guardrailVersion: "DRAFT"
```

## Using This Service with Same Guardrail

### Step 1: Set Environment Variables (Optional)

**Good news!** Your values are already configured as defaults:
- `BEDROCK_GUARDRAIL_ID` defaults to `v1qto5owq7gz`
- `BEDROCK_GUARDRAIL_VERSION` defaults to `DRAFT`
- `AWS_REGION` defaults to `us-west-2`
- `AWS_PROFILE` defaults to `pa`

The service is ready to run with no configuration needed!

```bash
# AWS Configuration (defaults already set for your guardrail)

# AWS Credentials (choose one method)
# Method 1: Use your existing AWS profile
export AWS_PROFILE=default

# Method 2: Use IAM role (if running on ECS/EKS)
# No configuration needed - automatic

# Method 3: Use access keys
export AWS_ACCESS_KEY_ID=your-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

### Step 2: Start the Service

**If AWS credentials are already configured** (via profile, IAM role, or environment):

```bash
cd /path/to/agentgateway/guardrail
python bedrock_guardrail.py
```

**That's it!** The service will use your defaults (`v1qto5owq7gz`, `DRAFT`, `us-west-2`, profile `pa`).

You should see:
```
INFO - Initializing Bedrock Guardrail client: guardrail=v1qto5owq7gz, version=DRAFT, region=us-west-2
INFO - AWS credentials loaded successfully
INFO - Bedrock Guardrails client initialized successfully
 * Running on http://127.0.0.1:7273
```

### Step 3: Test It

```bash
# In another terminal
python test_bedrock_guardrail.py
```

Or test manually:
```bash
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "messages": [
        {"role": "user", "content": "What is AI?"}
      ]
    }
  }'
```

## Configuration Options

### Blocking Modes

```bash
# Strict mode (default) - Block ALL violations including PII
export BEDROCK_BLOCKING_MODE=strict

# Balanced mode - Block serious violations, allow masked PII
export BEDROCK_BLOCKING_MODE=balanced

# Audit mode - Log only, never block (testing)
export BEDROCK_BLOCKING_MODE=audit
```

### Masking Options

```bash
# Enable PII masking in requests (default: true)
export BEDROCK_MASK_REQUESTS=true

# Enable PII masking in responses (default: true)
export BEDROCK_MASK_RESPONSES=true
```

## Integration Scenarios

### Scenario 1: Replace LiteLLM Guardrails

Route all traffic through this service instead of LiteLLM's native guardrails:

**Before (LiteLLM):**
```
Client → Agent Gateway → LiteLLM Guardrails → Bedrock Model
```

**After (This Service):**
```
Client → Agent Gateway → This Service (7273) → Bedrock Model
```

**Benefits:**
- Custom blocking modes
- Enhanced logging
- More control over masking behavior

### Scenario 2: Use Both Together

Use this service for pre-processing and LiteLLM for model calls:

```
Client → This Service (7273) → Agent Gateway → LiteLLM → Bedrock Model
                                                    ↓
                                          Same guardrail (v1qto5owq7gz)
```

**Benefits:**
- Dual-layer protection
- This service: Advanced logging and custom modes
- LiteLLM: Native Bedrock integration

### Scenario 3: Different Guardrails

Use this service with a different guardrail for different policies:

```bash
# This service - Custom guardrail for PII
export BEDROCK_GUARDRAIL_ID=pii-guardrail-id

# LiteLLM config - Content safety guardrail
guardrailIdentifier: v1qto5owq7gz
```

## Verifying It Works

### 1. Check Service Health

```bash
# Service should be running on port 7273
lsof -i :7273
```

### 2. Test Safe Content

```bash
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{"body": {"messages": [{"role": "user", "content": "Hello!"}]}}'
```

Expected response:
```json
{
  "action": {
    "reason": "No violations detected by Bedrock Guardrails"
  }
}
```

### 3. Test PII Detection

```bash
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{"body": {"messages": [{"role": "user", "content": "My email is test@example.com"}]}}'
```

Expected response (if PII filter configured):
```json
{
  "action": {
    "body": {
      "messages": [
        {"role": "user", "content": "My email is {EMAIL}"}
      ]
    },
    "reason": "Content sanitized by Bedrock Guardrails"
  }
}
```

### 4. Check Logs

The service logs all decisions:
```bash
# View real-time logs
tail -f bedrock_guardrail.log

# Or if running in foreground, see output directly
```

Look for:
- `INFO - Bedrock input result: action=GUARDRAIL_INTERVENED`
- `INFO - PII detected (anonymized): EMAIL`
- `INFO - Violations detected: ['pii:EMAIL']`

## Troubleshooting

### Error: "BEDROCK_GUARDRAIL_ID is required"

```bash
# Make sure you set the environment variable
export BEDROCK_GUARDRAIL_ID=v1qto5owq7gz
```

### Error: "Failed to load AWS credentials"

```bash
# Verify AWS credentials work
aws sts get-caller-identity

# If using profile
export AWS_PROFILE=your-profile

# If using access keys
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### Error: "Bedrock API returned 404"

```bash
# Verify guardrail exists
aws bedrock get-guardrail \
  --guardrail-identifier v1qto5owq7gz \
  --region us-east-1

# Check the region matches
export AWS_REGION=us-east-1
```

### No Violations Detected

This means:
1. Your guardrail is working correctly
2. The content doesn't violate configured policies
3. You may need to configure policies in your guardrail

To check guardrail configuration:
```bash
aws bedrock get-guardrail \
  --guardrail-identifier v1qto5owq7gz \
  --guardrail-version DRAFT \
  --region us-east-1
```

## Next Steps

1. **Configure Guardrail Policies** in AWS Console:
   - Content filtering (hate, violence, etc.)
   - PII detection (email, SSN, phone, etc.)
   - Topic restrictions
   - Word lists

2. **Test Different Content** with `test_bedrock_guardrail.py`

3. **Choose Blocking Mode** based on your needs:
   - Production: `strict` or `balanced`
   - Testing: `audit`

4. **Monitor Costs** via CloudWatch or log `usage` fields

5. **Integrate with Agent Gateway** routing

## Cost Estimation

Using your guardrail `v1qto5owq7gz`:

```
Example:
- 1000 requests/day
- Average 500 characters per request
- Content + PII policies enabled

Cost: ~$X.XX per day
(Check AWS Bedrock pricing for current rates)
```

Monitor usage in logs:
```
INFO - Bedrock usage: {'topicPolicyUnits': 0, 'contentPolicyUnits': 1, 'sensitiveInformationPolicyUnits': 1}
```

## Support

- **Full Documentation**: See `BEDROCK_README.md`
- **Implementation Details**: See `BEDROCK_IMPLEMENTATION_NOTES.md`
- **Comparison with Model Armor**: See `GUARDRAILS_COMPARISON.md`

## Quick Reference

```bash
# Start service (uses built-in defaults: v1qto5owq7gz, DRAFT, us-west-2, profile 'pa')
python bedrock_guardrail.py

# Test
curl -X POST http://127.0.0.1:7273/request \
  -H "Content-Type: application/json" \
  -d '{"body": {"messages": [{"role": "user", "content": "test"}]}}'

# Check status
lsof -i :7273

# View logs (if redirected)
tail -f bedrock_guardrail.log
```

You're ready to go! 🚀

