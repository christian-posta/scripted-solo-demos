openssl req -new -newkey rsa:4096 -x509 -sha256 \
    -days 3650 -nodes -out root-cert.pem -keyout root-key.pem \
    -subj "/O=posta-root-pki"
