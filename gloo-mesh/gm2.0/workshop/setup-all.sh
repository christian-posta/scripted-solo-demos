./setup-workshop.sh
./prep-demo.sh
./setup-gitops.sh


echo "Run the following to port forward the UIs"
echo "./port-forward-ui.sh"
echo "./gitops/gogs/port-forward-gogs.sh"
echo "./gitops/argocd/port-forward-argo.sh"
echo "(on HOST) ./ssh-port-forward.sh"