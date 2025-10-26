from flask import Flask, request, jsonify
import logging
import os
import json
from typing import Optional, Dict, Any, List, Literal
import boto3
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
from botocore.credentials import Credentials
import requests as http_requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Bedrock Guardrails Configuration
BEDROCK_CONFIG = {
    'guardrail_id': os.getenv('BEDROCK_GUARDRAIL_ID', 'v1qto5owq7gz'),
    'guardrail_version': os.getenv('BEDROCK_GUARDRAIL_VERSION', 'DRAFT'),
    'aws_region': os.getenv('AWS_REGION', os.getenv('AWS_DEFAULT_REGION', 'us-west-2')),
    'aws_access_key_id': os.getenv('AWS_ACCESS_KEY_ID'),
    'aws_secret_access_key': os.getenv('AWS_SECRET_ACCESS_KEY'),
    'aws_session_token': os.getenv('AWS_SESSION_TOKEN'),
    'aws_profile': os.getenv('AWS_PROFILE', 'pa'),
    'enabled': os.getenv('BEDROCK_GUARDRAIL_ENABLED', 'true').lower() == 'true',
    'mask_requests': os.getenv('BEDROCK_MASK_REQUESTS', 'true').lower() == 'true',
    'mask_responses': os.getenv('BEDROCK_MASK_RESPONSES', 'true').lower() == 'true',
    'fail_on_error': os.getenv('BEDROCK_FAIL_ON_ERROR', 'false').lower() == 'true',
    'blocking_mode': os.getenv('BEDROCK_BLOCKING_MODE', 'strict'),  # strict, balanced, audit
}


class BedrockGuardrailClient:
    """Client for Amazon Bedrock Guardrails API"""
    
    def __init__(
        self,
        guardrail_id: str,
        guardrail_version: str = "DRAFT",
        aws_region: str = "us-east-1",
        aws_access_key_id: Optional[str] = None,
        aws_secret_access_key: Optional[str] = None,
        aws_session_token: Optional[str] = None,
        aws_profile: Optional[str] = None
    ):
        self.guardrail_id = guardrail_id
        self.guardrail_version = guardrail_version
        self.aws_region = aws_region
        self.base_url = f"https://bedrock-runtime.{aws_region}.amazonaws.com"
        
        logger.info(f"Initializing Bedrock Guardrail client: guardrail={guardrail_id}, version={guardrail_version}, region={aws_region}")
        
        # Initialize AWS session and credentials
        try:
            self.session = self._create_session(
                aws_access_key_id,
                aws_secret_access_key,
                aws_session_token,
                aws_profile
            )
            self.credentials = self.session.get_credentials()
            if not self.credentials:
                raise ValueError("Failed to obtain AWS credentials")
            logger.info("AWS credentials loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load AWS credentials: {e}")
            raise
    
    def _create_session(
        self,
        access_key: Optional[str],
        secret_key: Optional[str],
        session_token: Optional[str],
        profile: Optional[str]
    ) -> boto3.Session:
        """Create boto3 session with provided credentials"""
        if profile:
            logger.debug(f"Using AWS profile: {profile}")
            return boto3.Session(profile_name=profile, region_name=self.aws_region)
        elif access_key and secret_key:
            logger.debug("Using explicit AWS credentials")
            return boto3.Session(
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
                aws_session_token=session_token,
                region_name=self.aws_region
            )
        else:
            logger.debug("Using default AWS credential chain")
            return boto3.Session(region_name=self.aws_region)
    
    def _sign_request(self, url: str, body: str) -> Dict[str, str]:
        """Sign request with AWS SigV4"""
        try:
            # Get frozen credentials
            frozen_credentials = self.credentials.get_frozen_credentials()
            
            # Create AWS request
            aws_request = AWSRequest(
                method='POST',
                url=url,
                data=body,
                headers={
                    'Content-Type': 'application/json',
                }
            )
            
            # Sign with SigV4
            signer = SigV4Auth(frozen_credentials, 'bedrock', self.aws_region)
            signer.add_auth(aws_request)
            
            # Return prepared headers
            return dict(aws_request.headers)
            
        except Exception as e:
            logger.error(f"Failed to sign AWS request: {e}")
            raise
    
    def apply_guardrail_input(
        self,
        messages: List[Dict[str, Any]],
        mask: bool = True
    ) -> Dict[str, Any]:
        """
        Apply guardrail to user input messages
        
        Returns:
            {
                'should_block': bool,
                'masked_content': Optional[List[str]],
                'reason': str,
                'action': str,
                'assessments': List[dict],
                'raw_response': dict
            }
        """
        # Convert messages to Bedrock content format
        content = self._convert_messages_to_content(messages)
        
        request_body = {
            "source": "INPUT",
            "content": content
        }
        
        logger.debug(f"Calling Bedrock ApplyGuardrail for INPUT")
        
        try:
            result = self._make_api_call(request_body)
            return self._process_guardrail_result(result, mask, "input", len(content))
            
        except Exception as e:
            logger.error(f"Error calling Bedrock Guardrail API: {e}", exc_info=True)
            raise
    
    def apply_guardrail_output(
        self,
        response_content: List[str],
        mask: bool = True
    ) -> Dict[str, Any]:
        """
        Apply guardrail to model output
        
        Returns:
            {
                'should_block': bool,
                'masked_content': Optional[List[str]],
                'reason': str,
                'action': str,
                'assessments': List[dict],
                'raw_response': dict
            }
        """
        # Convert response text to Bedrock content format
        content = [{"text": {"text": text}} for text in response_content]
        
        request_body = {
            "source": "OUTPUT",
            "content": content
        }
        
        logger.debug(f"Calling Bedrock ApplyGuardrail for OUTPUT")
        
        try:
            result = self._make_api_call(request_body)
            return self._process_guardrail_result(result, mask, "output", len(content))
            
        except Exception as e:
            logger.error(f"Error calling Bedrock Guardrail API: {e}", exc_info=True)
            raise
    
    def _make_api_call(self, request_body: Dict[str, Any]) -> Dict[str, Any]:
        """Make the actual API call to Bedrock"""
        endpoint = f"{self.base_url}/guardrail/{self.guardrail_id}/version/{self.guardrail_version}/apply"
        
        body = json.dumps(request_body)
        
        # Sign the request
        headers = self._sign_request(endpoint, body)
        
        logger.debug(f"POST {endpoint}")
        
        # Make the request
        response = http_requests.post(
            endpoint,
            data=body,
            headers=headers,
            timeout=30
        )
        
        logger.debug(f"Bedrock API response status: {response.status_code}")
        
        if response.status_code != 200:
            logger.error(f"Bedrock API error: {response.status_code} - {response.text}")
            raise Exception(f"Bedrock API returned {response.status_code}: {response.text}")
        
        result = response.json()
        logger.debug(f"Bedrock raw response: {json.dumps(result, indent=2)}")
        
        return result
    
    def _convert_messages_to_content(self, messages: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Convert OpenAI-style messages to Bedrock content format"""
        content = []
        
        for msg in messages:
            msg_content = msg.get('content', '')
            
            # Handle string content
            if isinstance(msg_content, str):
                content.append({"text": {"text": msg_content}})
            # Handle list content (multi-part messages)
            elif isinstance(msg_content, list):
                for part in msg_content:
                    if isinstance(part, dict) and part.get('type') == 'text':
                        content.append({"text": {"text": part.get('text', '')}})
                    elif isinstance(part, str):
                        content.append({"text": {"text": part}})
        
        return content
    
    def _process_guardrail_result(
        self,
        result: Dict[str, Any],
        mask: bool,
        content_type: str,
        original_content_count: int
    ) -> Dict[str, Any]:
        """Process the guardrail result from Bedrock"""
        action = result.get('action', 'NONE')
        assessments = result.get('assessments', [])
        outputs = result.get('outputs', [])
        usage = result.get('usage', {})
        
        logger.info(f"Bedrock {content_type} result: action={action}")
        
        # Determine if we should block based on blocking mode
        should_block = self._should_block(result, assessments)
        
        # Extract masked content if masking is enabled
        masked_content = None
        if mask and action == 'GUARDRAIL_INTERVENED' and outputs:
            masked_content = self._extract_masked_content(outputs, original_content_count)
        
        # Build detailed reason
        reason = self._build_reason(action, assessments, should_block)
        
        logger.info(f"Bedrock decision: should_block={should_block}, has_masked_content={masked_content is not None}, reason={reason}")
        
        # Log usage metrics
        if usage:
            logger.debug(f"Bedrock usage: {usage}")
        
        return {
            'should_block': should_block,
            'masked_content': masked_content,
            'reason': reason,
            'action': action,
            'assessments': assessments,
            'usage': usage,
            'raw_response': result
        }
    
    def _should_block(self, result: Dict[str, Any], assessments: List[Dict[str, Any]]) -> bool:
        """Determine if content should be blocked based on blocking mode"""
        blocking_mode = BEDROCK_CONFIG['blocking_mode']
        action = result.get('action', 'NONE')
        
        if action == 'NONE':
            return False
        
        # Collect all violations
        violations = []
        blocked_actions = []
        anonymized_actions = []
        
        for assessment in assessments:
            # Topic Policy
            topic_policy = assessment.get('topicPolicy', {})
            for topic in topic_policy.get('topics', []):
                topic_action = topic.get('action', '')
                if topic_action:
                    violations.append(f"topic:{topic.get('name', 'unknown')}")
                    if topic_action == 'BLOCKED':
                        blocked_actions.append(f"topic:{topic.get('name')}")
                        logger.warning(f"Topic policy violation: {topic}")
            
            # Content Policy
            content_policy = assessment.get('contentPolicy', {})
            for filter_item in content_policy.get('filters', []):
                filter_action = filter_item.get('action', '')
                if filter_action:
                    filter_type = filter_item.get('type', 'unknown')
                    violations.append(f"content:{filter_type}")
                    if filter_action == 'BLOCKED':
                        blocked_actions.append(f"content:{filter_type}")
                        logger.warning(f"Content policy violation: {filter_item}")
            
            # Word Policy
            word_policy = assessment.get('wordPolicy', {})
            for custom_word in word_policy.get('customWords', []):
                if custom_word.get('action'):
                    violations.append('word:custom')
                    if custom_word.get('action') == 'BLOCKED':
                        blocked_actions.append('word:custom')
                        logger.warning(f"Custom word violation: {custom_word.get('match')}")
            
            for managed_word in word_policy.get('managedWordLists', []):
                if managed_word.get('action'):
                    violations.append(f"word:managed:{managed_word.get('type', 'unknown')}")
                    if managed_word.get('action') == 'BLOCKED':
                        blocked_actions.append(f"word:managed:{managed_word.get('type')}")
                        logger.warning(f"Managed word violation: {managed_word}")
            
            # Sensitive Information Policy (PII)
            sensitive_info_policy = assessment.get('sensitiveInformationPolicy', {})
            for pii_entity in sensitive_info_policy.get('piiEntities', []):
                pii_action = pii_entity.get('action', '')
                if pii_action:
                    pii_type = pii_entity.get('type', 'unknown')
                    violations.append(f"pii:{pii_type}")
                    if pii_action == 'BLOCKED':
                        blocked_actions.append(f"pii:{pii_type}")
                        logger.warning(f"PII violation (blocked): {pii_type}")
                    elif pii_action == 'ANONYMIZED':
                        anonymized_actions.append(f"pii:{pii_type}")
                        logger.info(f"PII detected (anonymized): {pii_type}")
            
            for regex_match in sensitive_info_policy.get('regexes', []):
                if regex_match.get('action'):
                    violations.append(f"regex:{regex_match.get('name', 'unknown')}")
                    if regex_match.get('action') == 'BLOCKED':
                        blocked_actions.append(f"regex:{regex_match.get('name')}")
                        logger.warning(f"Regex pattern violation: {regex_match}")
                    elif regex_match.get('action') == 'ANONYMIZED':
                        anonymized_actions.append(f"regex:{regex_match.get('name')}")
            
            # Contextual Grounding Policy
            grounding_policy = assessment.get('contextualGroundingPolicy', {})
            for filter_item in grounding_policy.get('filters', []):
                if filter_item.get('action'):
                    violations.append('grounding')
                    if filter_item.get('action') == 'BLOCKED':
                        blocked_actions.append('grounding')
                        logger.warning(f"Contextual grounding violation: {filter_item}")
        
        # Blocking decision based on mode
        if blocking_mode == 'strict':
            # Block on any violation (including anonymized PII in strict mode)
            should_block = len(violations) > 0
        elif blocking_mode == 'balanced':
            # Block only on actual BLOCKED actions, not ANONYMIZED
            should_block = len(blocked_actions) > 0
        elif blocking_mode == 'audit':
            # Never block, just log
            should_block = False
        else:
            logger.warning(f"Unknown blocking mode: {blocking_mode}, defaulting to strict")
            should_block = len(violations) > 0
        
        if violations:
            logger.info(f"Violations detected: {violations}")
            logger.info(f"Blocked: {blocked_actions}, Anonymized: {anonymized_actions}")
            logger.info(f"Blocking mode: {blocking_mode}, should_block: {should_block}")
        
        return should_block
    
    def _extract_masked_content(self, outputs: List[Dict[str, Any]], expected_count: int) -> List[str]:
        """Extract masked/anonymized text from outputs"""
        masked_texts = []
        
        for output in outputs:
            text = output.get('text', '')
            if text:
                masked_texts.append(text)
        
        if masked_texts:
            logger.debug(f"Extracted {len(masked_texts)} masked content items")
        
        return masked_texts if masked_texts else None
    
    def _build_reason(self, action: str, assessments: List[Dict[str, Any]], should_block: bool) -> str:
        """Build a human-readable reason for the decision"""
        if action == 'NONE':
            return "No violations detected by Bedrock Guardrails"
        
        violations = []
        
        for assessment in assessments:
            # Check all policy types
            if assessment.get('topicPolicy', {}).get('topics'):
                topics = [t.get('name') for t in assessment['topicPolicy']['topics'] if t.get('action')]
                if topics:
                    violations.append(f"Restricted topic(s): {', '.join(topics)}")
            
            if assessment.get('contentPolicy', {}).get('filters'):
                content_types = [f.get('type') for f in assessment['contentPolicy']['filters'] if f.get('action')]
                if content_types:
                    violations.append(f"Content policy: {', '.join(content_types).lower()}")
            
            if assessment.get('wordPolicy', {}).get('customWords'):
                violations.append("Custom word filter")
            
            if assessment.get('wordPolicy', {}).get('managedWordLists'):
                word_types = [w.get('type') for w in assessment['wordPolicy']['managedWordLists'] if w.get('action')]
                if word_types:
                    violations.append(f"Managed words: {', '.join(word_types).lower()}")
            
            sensitive_info = assessment.get('sensitiveInformationPolicy', {})
            if sensitive_info.get('piiEntities'):
                pii_types = [p.get('type') for p in sensitive_info['piiEntities'] if p.get('action')]
                if pii_types:
                    violations.append(f"PII detected: {', '.join(pii_types)}")
            
            if sensitive_info.get('regexes'):
                violations.append("Custom regex pattern match")
            
            if assessment.get('contextualGroundingPolicy', {}).get('filters'):
                violations.append("Contextual grounding check failed")
        
        if not violations:
            return "Content flagged by Bedrock Guardrails (reason unknown)"
        
        action_word = "BLOCKED" if should_block else "FLAGGED"
        return f"{action_word}: {', '.join(violations)}"


# Initialize Bedrock client if enabled
guardrail_client = None
if BEDROCK_CONFIG['enabled']:
    if not BEDROCK_CONFIG['guardrail_id']:
        logger.error("BEDROCK_GUARDRAIL_ID is required but not set")
        if BEDROCK_CONFIG['fail_on_error']:
            raise ValueError("BEDROCK_GUARDRAIL_ID environment variable is required")
        else:
            logger.warning("Bedrock Guardrails disabled - BEDROCK_GUARDRAIL_ID not set")
            BEDROCK_CONFIG['enabled'] = False
    else:
        try:
            guardrail_client = BedrockGuardrailClient(
                guardrail_id=BEDROCK_CONFIG['guardrail_id'],
                guardrail_version=BEDROCK_CONFIG['guardrail_version'],
                aws_region=BEDROCK_CONFIG['aws_region'],
                aws_access_key_id=BEDROCK_CONFIG['aws_access_key_id'],
                aws_secret_access_key=BEDROCK_CONFIG['aws_secret_access_key'],
                aws_session_token=BEDROCK_CONFIG['aws_session_token'],
                aws_profile=BEDROCK_CONFIG['aws_profile']
            )
            logger.info("Bedrock Guardrails client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Bedrock Guardrails client: {e}")
            if BEDROCK_CONFIG['fail_on_error']:
                raise
            else:
                logger.warning("Bedrock Guardrails disabled due to initialization failure")
                BEDROCK_CONFIG['enabled'] = False
else:
    logger.info("Bedrock Guardrails is disabled by configuration")


@app.route('/request', methods=['POST'])
def validate_request():
    """Validate incoming prompts before they reach the LLM"""
    data = request.json
    messages = data.get('body', {}).get('messages', [])
    
    # Process messages with Bedrock Guardrails if enabled
    if guardrail_client and BEDROCK_CONFIG['enabled']:
        try:
            logger.info(f"Validating user prompt with Bedrock Guardrails ({len(messages)} messages)")
            
            # Call Bedrock Guardrail API
            guardrail_result = guardrail_client.apply_guardrail_input(
                messages=messages,
                mask=BEDROCK_CONFIG['mask_requests']
            )
            
            # Check if content should be blocked
            if guardrail_result['should_block']:
                logger.warning(f"REQUEST BLOCKED by Bedrock Guardrails: {guardrail_result['reason']}")
                return jsonify({
                    'action': {
                        'body': f"Request rejected by Bedrock Guardrails: {guardrail_result['reason']}",
                        'status_code': 403,
                        'reason': guardrail_result['reason']
                    }
                })
            
            # If content was masked, return the masked messages
            if guardrail_result.get('masked_content') and BEDROCK_CONFIG['mask_requests']:
                logger.info(f"REQUEST CONTENT MASKED by Bedrock Guardrails: {guardrail_result['reason']}")
                
                # Apply masked content back to messages
                masked_messages = []
                masked_texts = guardrail_result['masked_content']
                text_idx = 0
                
                for msg in messages:
                    if text_idx < len(masked_texts):
                        masked_messages.append({
                            'role': msg.get('role'),
                            'content': masked_texts[text_idx]
                        })
                        text_idx += 1
                
                logger.info("Returning sanitized request content")
                return jsonify({
                    'action': {
                        'body': {
                            'messages': masked_messages
                        },
                        'reason': 'Content sanitized by Bedrock Guardrails'
                    }
                })
            
            # Pass through if no violations or masking
            logger.info("Request passed Bedrock Guardrails validation")
            return jsonify({
                'action': {
                    'reason': 'No violations detected by Bedrock Guardrails'
                }
            })
            
        except Exception as e:
            logger.error(f"Error calling Bedrock Guardrails API: {e}", exc_info=True)
            
            if BEDROCK_CONFIG['fail_on_error']:
                return jsonify({
                    'action': {
                        'body': 'Bedrock Guardrails validation failed',
                        'status_code': 500,
                        'reason': f'Internal error: {str(e)}'
                    }
                })
            else:
                logger.warning("Bedrock Guardrails error - falling back to pass-through")
                return jsonify({
                    'action': {
                        'reason': 'Bedrock Guardrails unavailable, request passed through'
                    }
                })
    
    # If Bedrock Guardrails is disabled, pass through
    logger.info("Bedrock Guardrails disabled, request passed through")
    return jsonify({
        'action': {
            'reason': 'Bedrock Guardrails disabled'
        }
    })


@app.route('/response', methods=['POST'])
def validate_response():
    """Validate LLM responses before they reach the client"""
    data = request.json
    choices = data.get('body', {}).get('choices', [])
    
    # Process choices with Bedrock Guardrails if enabled
    if guardrail_client and BEDROCK_CONFIG['enabled']:
        try:
            # Extract response content
            response_texts = []
            for choice in choices:
                message = choice.get('message', {})
                content = message.get('content', '')
                if content:
                    response_texts.append(content)
            
            logger.info(f"Validating model response with Bedrock Guardrails ({len(response_texts)} responses)")
            
            # Call Bedrock Guardrail API
            guardrail_result = guardrail_client.apply_guardrail_output(
                response_content=response_texts,
                mask=BEDROCK_CONFIG['mask_responses']
            )
            
            # Check if content should be blocked
            if guardrail_result['should_block']:
                logger.warning(f"RESPONSE BLOCKED by Bedrock Guardrails: {guardrail_result['reason']}")
                return jsonify({
                    'action': {
                        'body': f"Response rejected by Bedrock Guardrails: {guardrail_result['reason']}",
                        'status_code': 403,
                        'reason': guardrail_result['reason']
                    }
                })
            
            # If content was masked, return the masked choices
            if guardrail_result.get('masked_content') and BEDROCK_CONFIG['mask_responses']:
                logger.info(f"RESPONSE CONTENT MASKED by Bedrock Guardrails: {guardrail_result['reason']}")
                
                # Apply masked content back to choices
                masked_choices = []
                masked_texts = guardrail_result['masked_content']
                
                for idx, choice in enumerate(choices):
                    if idx < len(masked_texts):
                        message = choice.get('message', {})
                        masked_choices.append({
                            'message': {
                                'role': message.get('role'),
                                'content': masked_texts[idx]
                            }
                        })
                
                logger.info("Returning sanitized response content")
                return jsonify({
                    'action': {
                        'body': {
                            'choices': masked_choices
                        },
                        'reason': 'Content sanitized by Bedrock Guardrails'
                    }
                })
            
            # Pass through if no violations or masking
            logger.info("Response passed Bedrock Guardrails validation")
            return jsonify({
                'action': {
                    'reason': 'No violations detected by Bedrock Guardrails'
                }
            })
            
        except Exception as e:
            logger.error(f"Error calling Bedrock Guardrails API: {e}", exc_info=True)
            
            if BEDROCK_CONFIG['fail_on_error']:
                return jsonify({
                    'action': {
                        'body': 'Bedrock Guardrails validation failed',
                        'status_code': 500,
                        'reason': f'Internal error: {str(e)}'
                    }
                })
            else:
                logger.warning("Bedrock Guardrails error - falling back to pass-through")
                return jsonify({
                    'action': {
                        'reason': 'Bedrock Guardrails unavailable, response passed through'
                    }
                })
    
    # If Bedrock Guardrails is disabled, pass through
    logger.info("Bedrock Guardrails disabled, response passed through")
    return jsonify({
        'action': {
            'reason': 'Bedrock Guardrails disabled'
        }
    })


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=7273)

