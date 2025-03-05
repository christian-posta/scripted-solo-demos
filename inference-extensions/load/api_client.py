#!/usr/bin/env python3
import subprocess
import time
import aiohttp
import asyncio
from typing import Dict, Any, Tuple


async def get_gateway_info() -> Tuple[str, int]:
    """Get the gateway IP and port from kubectl."""
    try:
        ip_process = subprocess.run(
            ["kubectl", "get", "gateway/inference-gateway", "-o", "jsonpath='{.status.addresses[0].value}'"],
            capture_output=True,
            text=True,
            check=True
        )
        ip = ip_process.stdout.strip("'")
        port = 8081
        return ip, port
    except subprocess.CalledProcessError as e:
        print(f"Error getting gateway info: {e}")
        return None, None


async def make_request(session: aiohttp.ClientSession, url: str, payload: Dict[str, Any], request_id: int) -> Dict[str, Any]:
    """Make a single request to the API."""
    start_time = time.time()
    try:
        async with session.post(url, json=payload) as response:
            elapsed = time.time() - start_time
            status = response.status
            
            # Try to get response data, but handle potential JSON parsing errors
            try:
                response_data = await response.json()
            except Exception as json_error:
                # If JSON parsing fails, get the raw text
                response_text = await response.text()
                response_data = {"error": f"Failed to parse JSON: {str(json_error)}", "raw_response": response_text[:500]}
            
            result = {
                "request_id": request_id,
                "status": status,
                "elapsed_time": elapsed,
                "prompt": payload.get("prompt", ""),
                "response": response_data,
                "timestamp": time.time()
            }
            
            # Add error details for non-200 responses
            if status != 200:
                result["error_details"] = {
                    "status_code": status,
                    "status_message": response.reason,
                    "headers": dict(response.headers),
                    "response_data": response_data
                }
            
            return result
            
    except aiohttp.ClientConnectorError as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "connection_error",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Connection error: {str(e)}",
            "error_details": {"type": "connection_error", "message": str(e)},
            "timestamp": time.time()
        }
    except aiohttp.ClientResponseError as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": e.status,
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Response error: {str(e)}",
            "error_details": {"type": "response_error", "status": e.status, "message": str(e)},
            "timestamp": time.time()
        }
    except asyncio.TimeoutError:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "timeout",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": "Request timed out",
            "error_details": {"type": "timeout"},
            "timestamp": time.time()
        }
    except Exception as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "error",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Unexpected error: {str(e)}",
            "error_details": {"type": "unexpected", "message": str(e), "exception_type": type(e).__name__},
            "timestamp": time.time()
        } 