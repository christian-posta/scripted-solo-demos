from flask import Flask, request, jsonify
import logging
import os
import json
from typing import Optional, Dict, Any
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests as http_requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Model Armor Configuration
MODEL_ARMOR_CONFIG = {
    'project_id': os.getenv('MODEL_ARMOR_PROJECT_ID', 'ceposta-solo-testing'),
    'location': os.getenv('MODEL_ARMOR_LOCATION', 'us-central1'),
    'template_id': os.getenv('MODEL_ARMOR_TEMPLATE_ID', 'litellm-guardrail'),
    'credentials_path': os.getenv('MODEL_ARMOR_CREDENTIALS', os.path.join(os.path.dirname(__file__), 'credentials.json')),
    'enabled': os.getenv('MODEL_ARMOR_ENABLED', 'true').lower() == 'true',
    'mask_requests': os.getenv('MODEL_ARMOR_MASK_REQUESTS', 'true').lower() == 'true',
    'mask_responses': os.getenv('MODEL_ARMOR_MASK_RESPONSES', 'true').lower() == 'true',
    'fail_on_error': os.getenv('MODEL_ARMOR_FAIL_ON_ERROR', 'false').lower() == 'true',
    'blocking_mode': os.getenv('MODEL_ARMOR_BLOCKING_MODE', 'strict'),  # strict, balanced, audit
}


class ModelArmorClient:
    """Client for Google Cloud Model Armor API"""
    
    def __init__(self, project_id: str, location: str, template_id: str, credentials_path: str):
        self.project_id = project_id
        self.location = location
        self.template_id = template_id
        self.credentials_path = credentials_path
        self.credentials = None
        self.base_url = f"https://modelarmor.{location}.rep.googleapis.com/v1"
        
        logger.info(f"Initializing Model Armor client: project={project_id}, location={location}, template={template_id}")
        
        # Initialize credentials
        try:
            self._load_credentials()
            logger.info("Model Armor credentials loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load Model Armor credentials: {e}")
            raise
    
    def _load_credentials(self):
        """Load service account credentials from file"""
        if not os.path.exists(self.credentials_path):
            raise FileNotFoundError(f"Credentials file not found: {self.credentials_path}")
        
        self.credentials = service_account.Credentials.from_service_account_file(
            self.credentials_path,
            scopes=['https://www.googleapis.com/auth/cloud-platform']
        )
        logger.debug("Service account credentials loaded")
    
    def _get_access_token(self) -> str:
        """Get or refresh access token"""
        try:
            if not self.credentials.valid:
                logger.debug("Refreshing access token")
                self.credentials.refresh(Request())
            return self.credentials.token
        except Exception as e:
            logger.error(f"Failed to get access token: {e}")
            raise
    
    def sanitize_user_prompt(self, content: str, mask: bool = True) -> Dict[str, Any]:
        """
        Sanitize user prompt through Model Armor
        
        Returns:
            {
                'should_block': bool,
                'sanitized_content': Optional[str],
                'reason': str,
                'filter_results': dict,
                'raw_response': dict
            }
        """
        endpoint = f"{self.base_url}/projects/{self.project_id}/locations/{self.location}/templates/{self.template_id}:sanitizeUserPrompt"
        
        request_body = {
            "userPromptData": {
                "text": content
            }
        }
        
        logger.debug(f"Calling Model Armor sanitizeUserPrompt endpoint: {endpoint}")
        
        try:
            access_token = self._get_access_token()
            headers = {
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json'
            }
            
            response = http_requests.post(
                endpoint,
                headers=headers,
                json=request_body,
                timeout=10
            )
            
            logger.debug(f"Model Armor API response status: {response.status_code}")
            
            if response.status_code != 200:
                logger.error(f"Model Armor API error: {response.status_code} - {response.text}")
                raise Exception(f"Model Armor API returned {response.status_code}: {response.text}")
            
            result = response.json()
            logger.debug(f"Model Armor raw response: {json.dumps(result, indent=2)}")
            
            return self._process_sanitization_result(result, mask, "user_prompt")
            
        except Exception as e:
            logger.error(f"Error calling Model Armor API: {e}", exc_info=True)
            raise
    
    def sanitize_model_response(self, content: str, mask: bool = True) -> Dict[str, Any]:
        """
        Sanitize model response through Model Armor
        
        Returns:
            {
                'should_block': bool,
                'sanitized_content': Optional[str],
                'reason': str,
                'filter_results': dict,
                'raw_response': dict
            }
        """
        endpoint = f"{self.base_url}/projects/{self.project_id}/locations/{self.location}/templates/{self.template_id}:sanitizeModelResponse"
        
        request_body = {
            "modelResponseData": {
                "text": content
            }
        }
        
        logger.debug(f"Calling Model Armor sanitizeModelResponse endpoint: {endpoint}")
        
        try:
            access_token = self._get_access_token()
            headers = {
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json'
            }
            
            response = http_requests.post(
                endpoint,
                headers=headers,
                json=request_body,
                timeout=10
            )
            
            logger.debug(f"Model Armor API response status: {response.status_code}")
            
            if response.status_code != 200:
                logger.error(f"Model Armor API error: {response.status_code} - {response.text}")
                raise Exception(f"Model Armor API returned {response.status_code}: {response.text}")
            
            result = response.json()
            logger.debug(f"Model Armor raw response: {json.dumps(result, indent=2)}")
            
            return self._process_sanitization_result(result, mask, "model_response")
            
        except Exception as e:
            logger.error(f"Error calling Model Armor API: {e}", exc_info=True)
            raise
    
    def _process_sanitization_result(self, result: Dict[str, Any], mask: bool, content_type: str) -> Dict[str, Any]:
        """Process the sanitization result from Model Armor"""
        sanitization_result = result.get('sanitizationResult', {})
        filter_match_state = sanitization_result.get('filterMatchState', 'UNKNOWN')
        filter_results = sanitization_result.get('filterResults', {})
        
        logger.info(f"Model Armor {content_type} result: filterMatchState={filter_match_state}")
        
        # Determine if we should block based on blocking mode
        should_block = self._should_block(filter_results, filter_match_state)
        
        # Extract sanitized content if masking is enabled
        sanitized_content = None
        if mask and filter_match_state == 'MATCH_FOUND':
            sanitized_content = self._get_sanitized_content(filter_results)
        
        # Build detailed reason
        reason = self._build_reason(filter_results, filter_match_state, should_block)
        
        logger.info(f"Model Armor decision: should_block={should_block}, has_sanitized_content={sanitized_content is not None}, reason={reason}")
        
        return {
            'should_block': should_block,
            'sanitized_content': sanitized_content,
            'reason': reason,
            'filter_results': filter_results,
            'filter_match_state': filter_match_state,
            'raw_response': result
        }
    
    def _should_block(self, filter_results: Dict[str, Any], filter_match_state: str) -> bool:
        """Determine if content should be blocked based on blocking mode"""
        blocking_mode = MODEL_ARMOR_CONFIG['blocking_mode']
        
        if filter_match_state == 'NO_MATCH_FOUND':
            return False
        
        # Check individual filter results
        violations = []
        
        # Handle both dict and list formats for filter_results
        filters = filter_results if isinstance(filter_results, dict) else {}
        
        # RAI (Responsible AI) filter
        if 'rai' in filters:
            rai_result = filters['rai'].get('raiFilterResult', {})
            if rai_result.get('matchState') == 'MATCH_FOUND':
                violations.append('rai')
                logger.warning(f"RAI filter violation detected: {rai_result}")
        
        # PI and Jailbreak filter
        if 'piAndJailbreakFilterResult' in filters:
            pi_result = filters['piAndJailbreakFilterResult']
            if pi_result.get('matchState') == 'MATCH_FOUND':
                violations.append('jailbreak')
                logger.warning(f"Jailbreak filter violation detected: {pi_result}")
        
        # Malicious URI filter
        if 'maliciousUriFilterResult' in filters:
            uri_result = filters['maliciousUriFilterResult']
            if uri_result.get('matchState') == 'MATCH_FOUND':
                violations.append('malicious_uri')
                logger.warning(f"Malicious URI filter violation detected: {uri_result}")
        
        # CSAM (Child Safety) filter
        if 'csamFilterFilterResult' in filters:
            csam_result = filters['csamFilterFilterResult']
            if csam_result.get('matchState') == 'MATCH_FOUND':
                violations.append('csam')
                logger.warning(f"CSAM filter violation detected: {csam_result}")
        
        # SDP (Sensitive Data Protection) filter
        if 'sdp' in filters:
            sdp_result = filters['sdp'].get('sdpFilterResult', {})
            inspect_result = sdp_result.get('inspectResult', {})
            if inspect_result.get('matchState') == 'MATCH_FOUND':
                violations.append('pii')
                findings = inspect_result.get('result', {}).get('findings', [])
                logger.info(f"SDP PII detected: {len(findings)} findings")
        
        # Blocking decision based on mode
        if blocking_mode == 'strict':
            # Block on any violation
            should_block = len(violations) > 0
        elif blocking_mode == 'balanced':
            # Block on serious violations only (not PII)
            serious_violations = [v for v in violations if v != 'pii']
            should_block = len(serious_violations) > 0
        elif blocking_mode == 'audit':
            # Never block, just log
            should_block = False
        else:
            logger.warning(f"Unknown blocking mode: {blocking_mode}, defaulting to strict")
            should_block = len(violations) > 0
        
        if violations:
            logger.info(f"Violations detected: {violations}, blocking_mode={blocking_mode}, should_block={should_block}")
        
        return should_block
    
    def _get_sanitized_content(self, filter_results: Dict[str, Any]) -> Optional[str]:
        """Extract sanitized content from filter results"""
        filters = filter_results if isinstance(filter_results, dict) else {}
        
        # Check SDP deidentify result
        if 'sdp' in filters:
            sdp_result = filters['sdp'].get('sdpFilterResult', {})
            deidentify_result = sdp_result.get('deidentifyResult', {})
            if deidentify_result.get('matchState') == 'MATCH_FOUND':
                data = deidentify_result.get('data', {})
                sanitized = data.get('text')
                if sanitized:
                    logger.debug(f"Extracted sanitized content from SDP deidentify result")
                    return sanitized
        
        return None
    
    def _build_reason(self, filter_results: Dict[str, Any], filter_match_state: str, should_block: bool) -> str:
        """Build a human-readable reason for the decision"""
        if filter_match_state == 'NO_MATCH_FOUND':
            return "No violations detected by Model Armor"
        
        violations = []
        filters = filter_results if isinstance(filter_results, dict) else {}
        
        if 'rai' in filters and filters['rai'].get('raiFilterResult', {}).get('matchState') == 'MATCH_FOUND':
            violations.append("RAI policy violation")
        
        if 'piAndJailbreakFilterResult' in filters and filters['piAndJailbreakFilterResult'].get('matchState') == 'MATCH_FOUND':
            violations.append("Prompt injection/jailbreak attempt")
        
        if 'maliciousUriFilterResult' in filters and filters['maliciousUriFilterResult'].get('matchState') == 'MATCH_FOUND':
            violations.append("Malicious URI detected")
        
        if 'csamFilterFilterResult' in filters and filters['csamFilterFilterResult'].get('matchState') == 'MATCH_FOUND':
            violations.append("CSAM content detected")
        
        if 'sdp' in filters:
            sdp_result = filters['sdp'].get('sdpFilterResult', {})
            if sdp_result.get('inspectResult', {}).get('matchState') == 'MATCH_FOUND':
                violations.append("PII/sensitive data detected")
        
        if not violations:
            return "Content flagged by Model Armor (reason unknown)"
        
        action = "BLOCKED" if should_block else "FLAGGED"
        return f"{action}: {', '.join(violations)}"


# Initialize Model Armor client if enabled
armor_client = None
if MODEL_ARMOR_CONFIG['enabled']:
    try:
        armor_client = ModelArmorClient(
            project_id=MODEL_ARMOR_CONFIG['project_id'],
            location=MODEL_ARMOR_CONFIG['location'],
            template_id=MODEL_ARMOR_CONFIG['template_id'],
            credentials_path=MODEL_ARMOR_CONFIG['credentials_path']
        )
        logger.info("Model Armor client initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Model Armor client: {e}")
        if MODEL_ARMOR_CONFIG['fail_on_error']:
            raise
        else:
            logger.warning("Model Armor disabled due to initialization failure")
            MODEL_ARMOR_CONFIG['enabled'] = False
else:
    logger.info("Model Armor is disabled by configuration")



@app.route('/request', methods=['POST'])
def validate_request():
    """Validate incoming prompts before they reach the LLM"""
    data = request.json
    messages = data.get('body', {}).get('messages', [])
    
    # Process messages with Model Armor if enabled
    if armor_client and MODEL_ARMOR_CONFIG['enabled']:
        try:
            processed_messages = []
            has_sanitized = False
            
            for msg in messages:
                content = msg.get('content', '')
                role = msg.get('role')
                
                logger.info(f"Validating user prompt with Model Armor (role={role})")
                
                # Call Model Armor API
                armor_result = armor_client.sanitize_user_prompt(
                    content=content,
                    mask=MODEL_ARMOR_CONFIG['mask_requests']
                )
                
                # Check if content should be blocked
                if armor_result['should_block']:
                    logger.warning(f"REQUEST BLOCKED by Model Armor: {armor_result['reason']}")
                    return jsonify({
                        'action': {
                            'body': f"Request rejected by Model Armor: {armor_result['reason']}",
                            'status_code': 403,
                            'reason': armor_result['reason']
                        }
                    })
                
                # Use sanitized content if available, otherwise original
                final_content = armor_result.get('sanitized_content') or content
                
                if armor_result.get('sanitized_content'):
                    logger.info(f"REQUEST CONTENT MASKED by Model Armor: {armor_result['reason']}")
                    has_sanitized = True
                
                processed_messages.append({
                    'role': role,
                    'content': final_content
                })
            
            # If any content was sanitized, return the masked messages
            if has_sanitized and MODEL_ARMOR_CONFIG['mask_requests']:
                logger.info("Returning sanitized request content")
                return jsonify({
                    'action': {
                        'body': {
                            'messages': processed_messages
                        },
                        'reason': 'Content sanitized by Model Armor'
                    }
                })
            
            # Pass through if no violations or masking
            logger.info("Request passed Model Armor validation")
            return jsonify({
                'action': {
                    'reason': 'No violations detected by Model Armor'
                }
            })
            
        except Exception as e:
            logger.error(f"Error calling Model Armor API: {e}", exc_info=True)
            
            if MODEL_ARMOR_CONFIG['fail_on_error']:
                return jsonify({
                    'action': {
                        'body': 'Model Armor validation failed',
                        'status_code': 500,
                        'reason': f'Internal error: {str(e)}'
                    }
                })
            else:
                logger.warning("Model Armor error - falling back to pass-through")
                return jsonify({
                    'action': {
                        'reason': 'Model Armor unavailable, request passed through'
                    }
                })
    
    # If Model Armor is disabled, pass through
    logger.info("Model Armor disabled, request passed through")
    return jsonify({
        'action': {
            'reason': 'Model Armor disabled'
        }
    })

@app.route('/response', methods=['POST'])
def validate_response():
    """Validate LLM responses before they reach the client"""
    data = request.json
    choices = data.get('body', {}).get('choices', [])
    
    # Process choices with Model Armor if enabled
    if armor_client and MODEL_ARMOR_CONFIG['enabled']:
        try:
            processed_choices = []
            has_sanitized = False
            
            for choice in choices:
                message = choice.get('message', {})
                content = message.get('content', '')
                role = message.get('role')
                
                logger.info(f"Validating model response with Model Armor (role={role})")
                
                # Call Model Armor API
                armor_result = armor_client.sanitize_model_response(
                    content=content,
                    mask=MODEL_ARMOR_CONFIG['mask_responses']
                )
                
                # Check if content should be blocked
                if armor_result['should_block']:
                    logger.warning(f"RESPONSE BLOCKED by Model Armor: {armor_result['reason']}")
                    return jsonify({
                        'action': {
                            'body': f"Response rejected by Model Armor: {armor_result['reason']}",
                            'status_code': 403,
                            'reason': armor_result['reason']
                        }
                    })
                
                # Use sanitized content if available, otherwise original
                final_content = armor_result.get('sanitized_content') or content
                
                if armor_result.get('sanitized_content'):
                    logger.info(f"RESPONSE CONTENT MASKED by Model Armor: {armor_result['reason']}")
                    has_sanitized = True
                
                processed_choices.append({
                    'message': {
                        'role': role,
                        'content': final_content
                    }
                })
            
            # If any content was sanitized, return the masked choices
            if has_sanitized and MODEL_ARMOR_CONFIG['mask_responses']:
                logger.info("Returning sanitized response content")
                return jsonify({
                    'action': {
                        'body': {
                            'choices': processed_choices
                        },
                        'reason': 'Content sanitized by Model Armor'
                    }
                })
            
            # Pass through if no violations or masking
            logger.info("Response passed Model Armor validation")
            return jsonify({
                'action': {
                    'reason': 'No violations detected by Model Armor'
                }
            })
            
        except Exception as e:
            logger.error(f"Error calling Model Armor API: {e}", exc_info=True)
            
            if MODEL_ARMOR_CONFIG['fail_on_error']:
                return jsonify({
                    'action': {
                        'body': 'Model Armor validation failed',
                        'status_code': 500,
                        'reason': f'Internal error: {str(e)}'
                    }
                })
            else:
                logger.warning("Model Armor error - falling back to pass-through")
                return jsonify({
                    'action': {
                        'reason': 'Model Armor unavailable, response passed through'
                    }
                })
    
    # If Model Armor is disabled, pass through
    logger.info("Model Armor disabled, response passed through")
    return jsonify({
        'action': {
            'reason': 'Model Armor disabled'
        }
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=7272)
