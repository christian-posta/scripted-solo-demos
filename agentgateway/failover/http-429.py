from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(429)
        self.send_header('Retry-After', '60')  # Evict for 10 seconds
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{"error":{"message":"Rate limit exceeded","type":"rate_limit_error"}}')
    
    def log_message(self, *args):
        pass  # Suppress logs
print("Dummy HTTP 429 server running on port 9959")

HTTPServer(('', 9959), Handler).serve_forever()
