To get started with this demo series:

```
./setup.sh
```

```
./port-forward-ui.sh
```

At time of writing, these demos have been verified with GlooEE 1.5.4

Some additional notes:

This demo env assumes specific DNS hostnames:

ceposta-gloo-demo.solo.io
ceposta-glooui-demo.solo.io
ceposta-petstore-demo.solo.io
ceposta-auth-demo.solo.io
ceposta-apis-demo.solo.io
ceposta-devportal-demo.solo.io

gloo-gogs.ceposta.demo.solo.io
gloo-argocd.ceposta.demo.solo.io

## Creating a new static IP on Gcloud:
gcloud compute addresses create ceposta-gloo-demo-ip --region us-west1
gcloud compute addresses describe ceposta-gloo-demo-ip --region us-west1
gcloud compute addresses describe ceposta-gloo-demo-ip --region us-west1 | grep address: | cut -d ' ' -f 2