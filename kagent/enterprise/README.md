

Based on doc here:
https://docs.solo.io/kagent-enterprise/docs/latest/quickstart/

Make sure /etc/hosts is:

```bash
127.0.0.1   keycloak-agent-identity.default
```

Deploy the keycloak pods:

```bash
kubectl apply -f ./enterprise/k8s-deployment.yaml
```

Once sorted, port forward Keycloak to `8080`

```bash
kubectl port-forward svc/keycloak-agent-identity 8080 -n default
```

Go to the UI and import:

Go to the UI to import the Realm
Go to the "realm settings" and import "partial import" Action in to right

Now you can deploy from the getting started, taking into account this setting:

```bash
helm upgrade -i kagent-enterprise \
oci://us-docker.pkg.dev/solo-public/kagent-enterprise-helm/charts/management \
-n kagent --create-namespace \
--version 0.1.0 \
--values enterprise/kagent-oidc-config.yaml \
--set cluster=nim-cluster
```

Make sure all the pods come up, and now you should port forward the UI, and the backend:

```bash
kubectl port-forward svc/kagent-enterprise-ui 8090:8090 -n kagent
kubectl port-forward svc/kagent-enterprise-ui 4000:4000 -n kagent
```

Go to the ui at `http://localhost:4000`