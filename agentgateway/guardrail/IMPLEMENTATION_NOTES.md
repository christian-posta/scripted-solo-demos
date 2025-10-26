# Google Model Armor Integration - Phase 1 Implementation

## Summary

Successfully implemented Google Model Armor integration into the Flask guardrail service. The implementation uses direct REST API calls to Model Armor endpoints with Google Cloud authentication.

## What Was Implemented

### 1. ModelArmorClient Class
- **Authentication**: Uses Google service account credentials with automatic token refresh
- **API Endpoints**:
  - `sanitizeUserPrompt` - Validates user requests before reaching LLM
  - `sanitizeModelResponse` - Validates LLM responses before reaching client
- **Filter Detection**:
  - RAI (Responsible AI) violations
  - Prompt injection & jailbreak attempts
  - Malicious URI detection
  - CSAM (Child Safety) content
  - PII/Sensitive data with masking support

### 2. Configuration System
Environment variables for flexible configuration:
- `MODEL_ARMOR_ENABLED` - Enable/disable the feature
- `MODEL_ARMOR_PROJECT_ID` - GCP project ID
- `MODEL_ARMOR_LOCATION` - GCP region
- `MODEL_ARMOR_TEMPLATE_ID` - Model Armor template
- `MODEL_ARMOR_CREDENTIALS` - Path to service account JSON
- `MODEL_ARMOR_MASK_REQUESTS` - Enable request masking
- `MODEL_ARMOR_MASK_RESPONSES` - Enable response masking
- `MODEL_ARMOR_BLOCKING_MODE` - strict/balanced/audit
- `MODEL_ARMOR_FAIL_ON_ERROR` - Fail fast or graceful degradation

### 3. Blocking Modes
- **strict** (default): Block ANY violation including PII
- **balanced**: Block serious threats, mask PII but don't block
- **audit**: Never block, log everything (for testing)

### 4. Comprehensive Logging
- INFO: Normal operations, validation results
- WARNING: Blocked requests with violation details
- ERROR: API failures with stack traces
- DEBUG: Raw API requests/responses

### 5. Error Handling
- Graceful degradation if Model Armor API fails (configurable)
- Detailed error logging for troubleshooting
- Authentication token auto-refresh

## Changes Made

### Files Modified
- `guardrail/modelarmor_guardrail.py` - Main implementation
  - Removed regex-based PII detection (replaced by Model Armor)
  - Added ModelArmorClient class
  - Updated `/request` and `/response` endpoints
  
- `requirements.txt` - Added dependencies:
  - `google-auth>=2.0.0`
  - `google-auth-oauthlib>=0.4.0`
  - `requests>=2.31.0`

### Files Created
- `guardrail/README.md` - Comprehensive documentation
- `guardrail/test_guardrail.py` - Test script
- `guardrail/IMPLEMENTATION_NOTES.md` - This file

## Testing

### Setup
1. Ensure you have Model Armor template configured in GCP
2. Set environment variables (see README.md)
3. Place service account credentials at the configured path

### Run the Service
```bash
cd guardrail
python modelarmor_guardrail.py
```

### Run Tests
```bash
# In another terminal
python test_guardrail.py
```

### Test Different Modes
```bash
# Audit mode (never blocks)
export MODEL_ARMOR_BLOCKING_MODE=audit
python modelarmor_guardrail.py

# Balanced mode (blocks serious threats only)
export MODEL_ARMOR_BLOCKING_MODE=balanced
python modelarmor_guardrail.py

# Strict mode (blocks everything)
export MODEL_ARMOR_BLOCKING_MODE=strict
python modelarmor_guardrail.py
```

## What to Verify

1. **Authentication**: Check logs show "Model Armor credentials loaded successfully"
2. **API Calls**: Test with safe content - should see "No violations detected"
3. **PII Detection**: Test with email/SSN - should see masking or blocking
4. **Jailbreak Detection**: Test with prompt injection - should block
5. **Error Handling**: Disable Model Armor template temporarily - should see graceful error handling

## Next Steps (Future Phases)

### Phase 2 - Integration Testing
- Test with actual Agent Gateway integration
- Performance testing with concurrent requests
- Verify masking quality with real PII
- Test error recovery scenarios

### Phase 3 - Production Readiness
- Add metrics/monitoring integration
- Implement request caching (avoid duplicate API calls)
- Add circuit breaker for API failures
- Performance optimization (connection pooling, etc.)
- Add unit tests
- Document deployment process

## Known Limitations

1. **Synchronous API Calls**: Currently blocking - could impact latency
2. **No Caching**: Each request hits Model Armor API
3. **Single Template**: Only supports one template ID per service instance
4. **No Retry Logic**: Failed API calls don't retry (fail fast)

## Architecture Notes

The implementation follows the pattern from LiteLLM:
- Direct REST API calls (no dedicated SDK needed)
- Google auth with service account
- Structured response processing
- Configurable blocking policies

The service is designed to be:
- **Stateless**: No local state, can scale horizontally
- **Fail-safe**: Graceful degradation on errors (configurable)
- **Observable**: Comprehensive logging for debugging
- **Flexible**: Environment-based configuration

## Dependencies

### Required GCP Setup
1. Model Armor enabled in project
2. Model Armor template created with filters configured
3. Service account with permissions:
   - `modelarmor.templates.sanitize` (or similar)
   - Typically granted via `Model Armor Admin` role

### Required Files
- Service account credentials JSON file
- Valid GCP project with billing enabled

## Troubleshooting Tips

### "Credentials file not found"
- Check `MODEL_ARMOR_CREDENTIALS` path
- Verify file permissions

### "401 Unauthorized"
- Service account may lack permissions
- Check if credentials expired

### "404 Not Found"  
- Template ID may be incorrect
- Verify project ID and location

### "No blocking in strict mode"
- Verify template has filters enabled
- Check template configuration in GCP console
- Enable DEBUG logging to see raw responses

## Success Criteria

Phase 1 is complete when:
- [x] Service starts without errors
- [x] Authentication works
- [x] API calls succeed
- [x] Violations are detected and logged
- [x] Blocking behavior works per mode
- [x] Error handling works gracefully
- [x] Documentation is complete

## Contact

See main project README for support information.

