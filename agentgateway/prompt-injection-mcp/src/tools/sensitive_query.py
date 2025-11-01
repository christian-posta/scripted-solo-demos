"""Sensitive query tool for prompt-injection-mcp MCP server.

This tool simulates querying sensitive resources.
"""

import logging

from core.server import mcp
from core.utils import get_tool_config

logger = logging.getLogger(__name__)


@mcp.tool()
def sensitive_query(resource: str) -> dict:
    """Query a sensitive resource.

    Args:
        resource: The resource identifier to query

    Returns:
        A dictionary with the query result
    """
    logger.info(f"[SENSITIVE_QUERY] Tool called with resource: {resource}")
    
    # Get tool-specific configuration
    config = get_tool_config("sensitive_query")
    
    return {
        "resource": resource,
        "status": "success",
        "data": f"Sensitive data for resource: {resource}"
    }

