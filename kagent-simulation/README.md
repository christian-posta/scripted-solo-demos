To run this demo:

On a working Kubernetes Cluster (or run `./setup-kind.sh`) run the following to set up ArgoCD:

```bash
./setup-argocd.sh
```

Then go to the argocd webpage and sync the application. Could check into using the cli to automate this if you want.

Once the app is up and running, check that it's working. Port-forward if you need to:

```bash
http://localhost:8081/ui/
```

Now you'll need to break the app by checking in a bad commit. 

The sample apps are here:

[https://github.com/christian-posta/aire-sample-apps](https://github.com/christian-posta/aire-sample-apps)

There are two branches that have bad commits that can be rebased to `main` to check in a breaking change. Run the following script:

```bash
./break-env-git.sh
```

In that script you'll can change which branch to use. 

e.g.

```bash
git checkout broken-scenario-incorrect-service-port
```

Once you've broken the environment, sync it from ArgoCD. 

You'll need to restart the frontend-v1:

```bash
kubectl rollout restart deployment/frontend-v1
```

Now go to the app in the UI again:

```bash
http://localhost:8081/ui/
```

We see things are broken. Now use https://kagent.dev to fix it following a GitOps approach. 

Use this prompt:

```text
Calling the frontend service at http://frontend-v1:8080 I see errors reaching backend-v1. These are running in the default namespace. 
```


---

You can also run this demo quickly w/o argo if you want. 

```bash
./setup-samples.sh
```

Then run the following to break the env:

```bash
./break-env.sh scenarios/<scenario_name>.yaml
```

Where <scenario_name> is the name of one of the yaml files in the `scenario` dir. 

If you want to pick it randomly (good effect for a demo)

```bash
./break-env.sh random
```
