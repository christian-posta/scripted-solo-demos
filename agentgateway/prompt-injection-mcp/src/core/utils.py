"""Shared utilities for prompt-injection-mcp MCP server."""

import os
from typing import Any

import yaml


def load_config(config_path: str) -> dict[str, Any]:
    """Load configuration from YAML file.

    Args:
        config_path: Path to the configuration file

    Returns:
        Configuration dictionary
    """
    try:
        with open(config_path) as f:
            return yaml.safe_load(f) or {}
    except FileNotFoundError:
        return {}
    except Exception as e:
        print(f"Error loading config from {config_path}: {e}")
        return {}


def get_shared_config() -> dict[str, Any]:
    """Get shared configuration that tools can access.

    Returns:
        Shared configuration dictionary
    """
    config = load_config("kmcp.yaml")
    tools_config = config.get("tools", {})
    if isinstance(tools_config, dict):
        return tools_config
    return {}


def get_tool_config(tool_name: str) -> dict[str, Any]:
    """Get configuration for a specific tool.

    Args:
        tool_name: Name of the tool

    Returns:
        Tool-specific configuration
    """
    shared_config = get_shared_config()
    tool_config = shared_config.get(tool_name, {})
    if isinstance(tool_config, dict):
        return tool_config
    return {}


def get_env_var(key: str, default: str = "") -> str:
    """Get environment variable with fallback.

    Args:
        key: Environment variable key
        default: Default value if not found

    Returns:
        Environment variable value or default
    """
    return os.environ.get(key, default)
