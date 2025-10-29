package authz

import rego.v1

# Helper functions to access the Envoy ext_authz structure
source_ip := input.attributes.source.address.socketAddress.address

http_method := input.attributes.request.http.method

http_path := input.attributes.request.http.path

# Get header value (case-insensitive by accessing lowercased headers)
get_header(name) := input.attributes.request.http.headers[lower(name)]

# Get context extension
get_context(name) := input.attributes.contextExtensions[name]

# Default deny
default allowed := false

# Check if body exists in input
has_body if {
    input.attributes.request.http.body
}

# Parse the JSON body only if it exists
request_body := json.unmarshal(input.attributes.request.http.body) if {
    has_body
}

# Extract the model from the request body
request_model := request_body.model if {
    request_body
}

# Check if model starts with gpt-3.5
is_allowed_model if {
    request_model
    startswith(request_model, "gpt-3.5")
}

# Check if we're in development mode
is_development if {
    get_context("environment") == "development"
}

# Check if the required header is present
has_passthrough_header if {
    get_header("x-opa-passthrough-enabled") == "true"
}

# Check if path starts with /opa/openai (should already be matched by route)
is_correct_path if {
    startswith(http_path, "/opa/openai")
}

# ALLOW: When all conditions are met
allowed if {
    is_correct_path
    has_passthrough_header
    is_development
    is_allowed_model
}

# ALLOW: Always allow OPTIONS for CORS
allowed if {
    http_method == "OPTIONS"
}

# Provide detailed denial reason
reason contains msg if {
    not is_correct_path
    msg := "Path must start with /opa/openai"
}

reason contains msg if {
    not has_passthrough_header
    msg := "Missing or invalid header: x-opa-passthrough-enabled must be 'true'"
}

reason contains msg if {
    is_development
    not has_body
    msg := "Request body is missing. Cannot validate model requirement."
}

reason contains msg if {
    is_development
    has_body
    not request_model
    msg := "Model field is missing from request body"
}

reason contains msg if {
    is_development
    request_model
    not is_allowed_model
    msg := sprintf("Model '%s' is not allowed in development. Only gpt-3.5-* models are permitted", [request_model])
}

reason contains msg if {
    not is_development
    msg := "Not in development environment"
}