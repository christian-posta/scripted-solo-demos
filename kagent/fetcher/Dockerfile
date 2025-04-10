FROM python:3.11-slim
WORKDIR /app
# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy application code
COPY app.py .
# Expose the port the app runs on
EXPOSE 8000
# Run the application
CMD ["python", "app.py", "--port", "8000"]
