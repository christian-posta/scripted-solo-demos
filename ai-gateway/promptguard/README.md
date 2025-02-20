
source .venv/bin/activate

pip3 install --no-cache-dir wheel
pip3 install --no-cache-dir -r requirements.txt

python3 -m fastapi dev --host 0.0.0.0 ./app.py



## Build the Docker image
docker build -t presidio-guardrail .

## Expose on NGROK:
After running with ./run_local.sh the service will run on 8000.

```bash
ngrok  http http://0.0.0.0:8000 --scheme http
```

Then take the ngrok HTTP url and put it into the promptguard configuration. 