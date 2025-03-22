FROM alpine:3.19

# Install bash and other dependencies
RUN apk add --no-cache bash curl bc

# Install Fortio from its releases
RUN curl -L https://github.com/fortio/fortio/releases/download/v1.60.3/fortio-linux_amd64-1.60.3.tgz > fortio.tgz && \
    mkdir -p fortio-tmp && \
    tar -xzf fortio.tgz -C fortio-tmp && \
    mv fortio-tmp/usr/bin/fortio /usr/local/bin/ && \
    chmod +x /usr/local/bin/fortio && \
    rm -rf fortio-tmp fortio.tgz

# Set working directory
WORKDIR /app

# Copy the load testing script
COPY run-load.sh .

# Set environment variables (these can be overridden at runtime)
ENV GATEWAY_URL="http://localhost:8080" \
    PRODUCTPAGE_PATH="/productpage" \
    LOG_DIR="/app/fortio-logs"

# Create log directory
RUN mkdir -p /app/fortio-logs && \
    chmod +x /app/run-load.sh

# Command to run the script
CMD ["/app/run-load.sh"] 