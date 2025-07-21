## TL;DR 

Port forward these:

```bash
8080 - ArgoCD
8081 - Sample Apps / frontend-v1
8082 - Kagent UI
```

```bash
./setup-argocd.sh
```

Use the following Agent:

```bash
kubectl apply -f aire-agent.yaml
```

This is the prompt you want to use:

```markdown
Calling the frontend service at http://frontend-v1:8080 I see errors reaching backend-v1. The apps are running in the default namespace. 
```

If you need to follow up with the GH PR prompt:


```markdown
GH repo name: https://github.com/christian-posta/aire-sample-apps
Create the branch from main. 
You can call it "fix-live-demo-branch"
The backend-v1 service is in the backend-v1.yaml file, can you check the GH repo?
```



## To run this demo:

For the GH Personal Access Token, make sure you give it the following permissions:

- Contents
- Pull Requests
- Issues

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
Calling the frontend service at http://frontend-v1:8080 I see errors reaching backend-v1. The apps are running in the default namespace. 
```


Make sure you have the GH tools (MCP Server) installed on kagent:

```bash
cd resources/kagent
./setup-ghtools.sh
```

You'll need to give your agent access to the Pull Request Tools. 

At the moment, the UI limits tools to 10. Follow this Issue for more: https://github.com/kagent-dev/kagent/issues/367

To get around this, add the tool through the YAML:

```bash
cd resources/kagent
kubectl apply -f aire-agent.yaml
```

When it's time to prompt for the GH PR, use something like:

```text
GH repo name: https://github.com/christian-posta/aire-sample-apps
Create the branch from main. 
You can call it "fix-live-demo-branch"
The backend-v1 service is in the backend-v1.yaml file, can you check the GH repo?
```

---

## Running Demo Without Argo

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
