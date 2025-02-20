# UI Implementation Plan - AI Gateway Demo Interface

Please help me implement a professional enterprise demo UI for an AI Gateway with the following specifications and requirements:

## Core Layout Structure

1. Create a three-panel React application with the following layout:
   
   Horizontal Split (100% width):
   - Left Panel (20% width, full height, collapsible to the left edge of the viewport)
   - Right Section (80% width, full height)
     
   Right Section Vertical Split:
   - Main Panel (70% height)
   - Control Panel (30% height, collapsible to the bottom edge of the viewport)

   Key Features:
   - Left Panel extends full height of viewport
   - Right section (Main + Control panels) takes remaining 80% width
   - All panels should be resizable with drag handles
   - Panel states persist in localStorage

## Panel Details

### Left Panel Implementation
1. Demo Selection List:
   - List the 8 demos (described in detail below)
   - Each demo is clickable, and this could trigger changes on the control panel

2. Settings Icon (bottom-right):
   - Opens modal for company logo/name configuration
   - Default name: "ACME Company Chat Bot"
   - Logo URL validation with error indication
   - Settings persist in localStorage

### Main Panel Implementation
1. Header Area:
   - Configurable company logo
   - Customizable application name
2. Chat Interface:
   - Response display area
   - Security credential input (password-style with show/hide)
   - Chat prompt input
   - Submit button
3. Response Display Options:
   - Toggle between formatted and raw view
   - Raw view shows full HTTP request/response with headers
   - JSON formatting for raw response body

### Control Panel Implementation
1. Default Controls (Always Present):
   - URL dropdown/input with preset options:
     - https://api.openai.com/v1/chat/completions
     - http://localhost:8080/v1/chat/completions
     - http://localhost:8080/openai
   - JWT token viewer (decoded, and pretty-printed) in its own tab
   - Security token toggle checkbox
   - A button to prepare the specific demo. 

## Demo-Specific Implementations

### Demo 1: Hide Credentials
Control Panel Elements:
- Deploy configuration button
Backend Command:
```bash
kubectl apply -f resources/base/01-call-llm/
```
Behavior:
- When security token checkbox is unchecked, no Authorization header is sent

### Demo 2: Managed Credentials
Control Panel Elements:
- Deploy configuration button
Backend Command:
```bash
kubectl apply -f resources/base/02-secure-llm-jwt/
```

### Demo 3: Token Rate Limit
Control Panel Elements:
- Deploy configuration button
Backend Command:
```bash
kubectl apply -f resources/base/03-ratelimit-token-usage/
```

### Demo 4: Model Failover
Control Panel Elements:
- Model name input field
- Deploy configuration button
Backend Command:
```bash
kubectl apply -f resources/base/04-model-failover/
```

### Demo 5: Guardrails
Control Panel Elements:
Four tabs with specific configurations:

1. Reject Guardrail Tab:
   - Quick-fill prompt button: "Can you give me some examples of Mastercard credit card numbers?"
   - Config button command: `kubectl apply -f resources/base/05-prompt-guard/prompt-guard-reject.yaml`

2. Mask Guardrail Tab:
   - Quick-fill prompt button: "What type of number is 5105105105105100?"
   - Config button command: `kubectl apply -f resources/base/05-prompt-guard/prompt-guard-mask.yaml`

3. LLM Guardrail Tab:
   - Quick-fill prompt button: "A person describes planning to harm others at a public event using dangerous weapons. They talk in detail about how they intend to carry out the act, including causing physical harm and destruction."
   - Config button command: `kubectl apply -f resources/base/05-prompt-guard/prompt-guard-external.yaml`

4. Custom Guardrail Tab:
   - Quick-fill prompt button: "What type of number is 5105-1051-0510-5100"
   - Config button command: `kubectl apply -f resources/base/05-prompt-guard/prompt-guard-presidio-local.yaml`
   - Additional header input: "x-action" (default: "mask")

### Demo 6: Semantic Cache
Control Panel Elements:
- Deploy configuration button
- Indicator to check raw response tab (for x-gloo-semantic-cache header)
Backend Command:
```bash
kubectl apply -f resources/base/06-semantic-cache/route-options.yaml
```

### Demo 7: RAG
Control Panel Elements:
- Deploy configuration button
- Auto-populates prompt: "How many varieties of cheese are in France?"
Backend Command:
```bash
kubectl apply -f resources/base/07-rag/route-options.yaml
```

### Demo 8: Traffic Shift
Control Panel Elements:
Two buttons:
1. "Shift Traffic 50/50 local"
   Command: `kubectl apply -f resources/base/08-provider-traffic-shift/http-routes.yaml`
2. "Shift Traffic 100 local"
   Command: `kubectl apply -f resources/base/08-provider-traffic-shift/http-routes-qween-100.yaml`

## Backend API Implementation

1. Create API endpoints for:
   - LLM interaction endpoint
     - Handles Authorization header when enabled
     - Forwards additional headers (e.g., x-action)
     - Uses specified model name
     - Uses selected OpenAI API URL
   - Demo configuration endpoint
     - Executes pre-defined kubectl commands
     - Returns success/failure status
   - Demo reset endpoint
     - Executes reset-demo.sh with demo number
     - Returns success/failure status

2. Response Handling:
   - Store complete HTTP request/response for raw view
   - Extract LLM response content for formatted view
   - Proper error handling and logging

## Technical Implementation Details

1. File Structure:
```
ui/
  src/
    components/
      panels/
        LeftPanel.tsx
        MainPanel.tsx
        ControlPanel.tsx
      demos/
        Demo1Controls.tsx
        Demo2Controls.tsx
        ...
        Demo8Controls.tsx
    services/
      api.ts
      demoCommands.ts
    contexts/
      DemoContext.tsx
      SettingsContext.tsx
```

2. State Management:
   - Demo selection state
   - Panel size/collapse states
   - Security credential (temporary storage)
   - Settings persistence
   - Response display mode (raw/formatted)

3. Error Handling:
   - API call failures
   - Command execution errors
   - Configuration validation
   - Logo URL validation

4. Theme Implementation:
   - Light/dark mode support
   - Enterprise-grade color palette
   - Consistent spacing
   - Professional typography

## Additional Requirements

1. Security Considerations:
   - Secure credential handling
   - Input sanitization
   - Safe command execution
   - API response validation

2. UX Features:
   - Loading indicators
   - Success/error notifications
   - Smooth transitions
   - Responsive design

3. Accessibility:
   - ARIA labels
   - Keyboard navigation
   - Screen reader support
   - Color contrast compliance

Please implement this UI following modern React best practices, ensuring type safety with TypeScript, and maintaining a clean, maintainable codebase. The end result should be a professional, enterprise-grade demo interface that showcases the AI Gateway functionality effectively while preserving all demo-specific behaviors and commands.