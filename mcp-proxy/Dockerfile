ARG VERSION="0.4.1"
FROM ghcr.io/agentproxy-dev/agentproxy:${VERSION} as source

FROM ghcr.io/astral-sh/uv:0.6.5-debian-slim AS final

COPY --from=source /app/agentproxy /bin/agentproxy

ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    gnupg \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

WORKDIR /app
ENTRYPOINT ["/bin/agentproxy"]