FROM python:3.10-slim-bookworm AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.10-slim-bookworm

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]