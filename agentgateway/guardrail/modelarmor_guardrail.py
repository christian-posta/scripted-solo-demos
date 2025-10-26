from flask import Flask, request, jsonify
import re
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Example patterns to detect
PII_PATTERNS = {
    'ssn': r'\b\d{3}-\d{2}-\d{4}\b',
    'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    'credit_card': r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
}

def check_and_mask_content(content, mask=True):
    """Check content for PII and optionally mask it"""
    violations = []
    masked_content = content
    
    for pattern_name, pattern in PII_PATTERNS.items():
        matches = re.findall(pattern, content)
        if matches:
            violations.append(pattern_name)
            if mask:
                masked_content = re.sub(pattern, '[REDACTED]', masked_content)
    
    return violations, masked_content

@app.route('/request', methods=['POST'])
def validate_request():
    """Validate incoming prompts before they reach the LLM"""
    data = request.json
    messages = data.get('body', {}).get('messages', [])
    
    # Check all messages for violations
    all_violations = []
    masked_messages = []
    
    for msg in messages:
        content = msg.get('content', '')
        violations, masked_content = check_and_mask_content(content, mask=True)
        all_violations.extend(violations)
        
        masked_messages.append({
            'role': msg.get('role'),
            'content': masked_content
        })
    

    # Policy: Reject if SSN detected, mask for other PII
    if 'ssn' in all_violations:
        logger.warning(f'REQUEST REJECTED: SSN detected - violations: {", ".join(all_violations)}')
        return jsonify({
            'action': {
                'body': 'Request rejected: SSN detected in prompt',
                'status_code': 403,
                'reason': f'Policy violation: {", ".join(all_violations)}'
            }
        })        
    

    # Mask other PII
    if all_violations:
        logger.info(f'REQUEST MASKED: PII detected and masked - violations: {", ".join(all_violations)}')
        return jsonify({
            'action': {
                'body': {
                    'messages': masked_messages
                },
                'reason': f'Masked: {", ".join(all_violations)}'
            }
        })        
    
    # Pass through if no violations
    return jsonify({
        'action': {
            'reason': 'No violations detected'
        }
    })

@app.route('/response', methods=['POST'])
def validate_response():
    """Validate LLM responses before they reach the client"""
    data = request.json
    choices = data.get('body', {}).get('choices', [])
    
    # Check all choices for violations
    all_violations = []
    masked_choices = []
    
    for choice in choices:
        message = choice.get('message', {})
        content = message.get('content', '')
        violations, masked_content = check_and_mask_content(content, mask=True)
        all_violations.extend(violations)
        
        masked_choices.append({
            'message': {
                'role': message.get('role'),
                'content': masked_content
            }
        })
    
    # Mask any PII in responses
    if all_violations:
        logger.info(f'RESPONSE MASKED: PII detected in LLM response and masked - violations: {", ".join(all_violations)}')
        return jsonify({
            'body': {
                'choices': masked_choices
            },
            'reason': f'Masked PII in response: {", ".join(all_violations)}',
            'mask': {}
        })
    
    # Pass through if no violations
    return jsonify({
        'reason': 'No PII detected',
        'pass': {}
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=7272)
