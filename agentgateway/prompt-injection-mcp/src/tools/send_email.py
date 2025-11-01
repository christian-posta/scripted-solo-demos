"""Send email tool for prompt-injection-mcp MCP server.

This tool simulates sending emails.
"""

import logging

from core.server import mcp
from core.utils import get_tool_config

logger = logging.getLogger(__name__)


@mcp.tool()
def send_email(email: str, recipient: str) -> dict:
    """Send an email.

    Args:
        email: The email content to send
        recipient: The email recipient address

    Returns:
        A dictionary with the send result
    """
    logger.info(f"[SEND_EMAIL] Tool called with recipient: {recipient}, email content: {email[:100]}...")
    
    # Get tool-specific configuration
    config = get_tool_config("send_email")
    
    return {
        "status": "sent",
        "recipient": recipient,
        "email": email,
        "message": f"Email sent successfully to {recipient}: {email[:50]}..."
    }

