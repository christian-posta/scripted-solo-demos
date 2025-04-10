kubectl apply -f - <<EOF
apiVersion: kagent.dev/v1alpha1
kind: Agent
metadata:
  name: my-first-agent
  namespace: kagent
spec:
  description: This agent can use a single tool to retrieve the contents of a webpage.
  modelConfigRef: default-model-config
  systemMessage: |-
    You're a friendly and helpful agent that uses the fetch tool to retrieve webpage contents.

    # Instructions

    - If user question is unclear, ask for clarification before running any tools
    - Always be helpful and friendly
    - If you don't know how to answer the question DO NOT make things up
      respond with "Sorry, I don't know how to answer that" and ask the user to further clarify the question

    # Response format
    - ALWAYS format your response as Markdown
    - Your response will include a summary of actions you took and an explanation of the result
  tools:
    - provider: autogen_ext.tools.mcp.SseMcpToolAdapter
      config:
        server_params:
          sse_read_timeout: "300"
          timeout: "5"
          url: http://mcp-website-fetcher.kagent.svc.cluster.local/sse
        tool:
          name: fetch
          description: Fetches a website and returns its content
          inputSchema:
            type: object
            properties:
              url:
                type: string
                description: URL to fetch
            required:
              "0": url
EOF


Show me the contents of https://en.wikipedia.org/wiki/Service_mesh website