
docker build -t presidio-guardrail .

kind load docker-image presidio-guardrail:latest --name kind1