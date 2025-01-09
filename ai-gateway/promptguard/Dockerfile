# Stage 1: Build the application
FROM python:3.10-slim-bookworm AS build

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire application code into the container
COPY . .

# Expose the port that the app runs on
EXPOSE 8000

# Command to run the FastAPI application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

------


    
FROM python:3.9-slim-buster AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

COPY requirements.txt /
RUN pip install --user -r requirements.txt

FROM python:3.9-slim-buster

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY ./app /app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]