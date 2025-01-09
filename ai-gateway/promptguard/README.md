
source .venv/bin/activate

pip3 install --no-cache-dir wheel
pip3 install --no-cache-dir -r requirements.txt

python3 -m fastapi dev --host 0.0.0.0 ./app.py



## Build the Docker image
docker build -t presidio-guardrail .

