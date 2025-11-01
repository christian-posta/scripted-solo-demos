# prompt-injection-mcp

prompt-injection-mcp is a Model Context Protocol (MCP) server built with FastMCP featuring dynamic tool loading.

## Features

- **Dynamic Tool Loading**: Tools are automatically discovered and loaded from `src/tools/`
- **One Tool Per File**: Each tool is a single file with a function matching the filename
- **FastMCP Integration**: Leverages FastMCP for robust MCP protocol handling
- **Configuration Management**: Tool-specific configuration via `kmcp.yaml`
- **Fail-Fast**: Server won't start if any tool fails to load
- **Auto-Generated Tests**: Automatic test generation for tool validation

## Project Structure

```
src/
├── tools/              # Tool implementations (one file per tool)
│   ├── echo.py         # Example echo tool
│   └── __init__.py     # Auto-generated tool registry
├── core/               # Dynamic loading framework
│   ├── server.py       # Dynamic MCP server
│   └── utils.py        # Shared utilities
└── main.py             # Entry point
kmcp.yaml               # Configuration file
tests/                  # Generated tests
```

## Quick Start

### Option 1: Local Development (with Python/uv)

1. **Install Dependencies**:
   ```bash
   uv sync
   ```

2. **Run the Server**:
   ```bash
   # Stdio mode (default MCP transport)
   uv run python src/main.py
   
   # HTTP mode with WebSocket MCP endpoint
   uv run python src/main.py --http
   
   # HTTP mode with custom host/port
   uv run python src/main.py --http --host 0.0.0.0 --port 8080
   ```

3. **Using uv Scripts**:
   ```bash
   # Development mode (HTTP on port 3000)
   uv run dev
   
   # HTTP mode
   uv run dev-http
   
   # Stdio mode
   uv run start
   ```

4. **Add New Tools**:
   ```bash
   # Create a new tool (no tool types needed!)
   kmcp add-tool weather
   
   # The tool file will be created at src/tools/weather.py
   # Edit it to implement your tool logic
   ```

### Option 2: Docker-Only Development (no local Python/uv required)

1. **Build Docker Image**:
   ```bash
   kmcp build --verbose
   ```

2. **Run in Container**:
   ```bash
   docker run -i prompt-injection-mcp:latest
   ```

3. **Deploy to Kubernetes**:
   ```bash
   kmcp deploy mcp --apply
   ```

4. **Add New Tools**:
   ```bash
   # Create a new tool
   kmcp add-tool weather
   
   # Edit the tool file, then rebuild
   kmcp build
   ```

## HTTP Transport Mode

The server supports running in HTTP mode for development and integration purposes.

### Starting in HTTP Mode

```bash
# Command line flag
python src/main.py --http

# Environment variable
MCP_TRANSPORT_MODE=http python src/main.py

# Custom host and port
python src/main.py --http --host localhost --port 8080
```

## Creating Tools

### Basic Tool Structure

Each tool is a Python file in `src/tools/` containing a function decorated with `@mcp.tool()`:

```python
# src/tools/weather.py
from core.server import mcp
from core.utils import get_tool_config, get_env_var

@mcp.tool()
def weather(location: str) -> str:
    """Get weather information for a location."""
    
    # Get tool configuration
    config = get_tool_config("weather")
    api_key = get_env_var(config.get("api_key_env", "WEATHER_API_KEY"))
    base_url = config.get("base_url", "https://api.openweathermap.org/data/2.5")
    
    # TODO: Implement weather API call
    return f"Weather for {location}: Sunny, 72°F"
```

### Tool Examples

The generated tool template includes commented examples for common patterns:

```python
# HTTP API calls
# async with httpx.AsyncClient() as client:
#     response = await client.get(f"{base_url}/weather?q={location}&appid={api_key}")
#     return response.json()

# Database operations  
# async with asyncpg.connect(connection_string) as conn:
#     result = await conn.fetchrow("SELECT * FROM weather WHERE location = $1", location)
#     return dict(result)

# File processing
# with open(file_path, 'r') as f:
#     content = f.read()
#     return {"content": content, "size": len(content)}
```

## Configuration

Configure tools in `kmcp.yaml`:

```yaml
tools:
  weather:
    api_key_env: "WEATHER_API_KEY"
    base_url: "https://api.openweathermap.org/data/2.5"
    timeout: 30
  
  database:
    connection_string_env: "DATABASE_URL"
    max_connections: 10
```

## Testing

Run the generated tests to verify your tools load correctly:

```bash
uv run pytest tests/
```

## Development

### Adding Dependencies

Update `pyproject.toml` and run:

```bash
uv sync
```

### Code Quality

```bash
uv run black .
uv run ruff check .
uv run mypy .
```

## Deployment

### Docker

```bash
# Build image (handles lockfile automatically)
kmcp build

# Run container
docker run -i prompt-injection-mcp:latest
```

### Kubernetes

```bash
# Deploy to Kubernetes
kmcp deploy mcp --apply

# Check deployment status
kubectl get mcpserver prompt-injection-mcp
```