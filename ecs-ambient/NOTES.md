
#### We will let eksctl create the VPC for us
eksctl create cluster --config-file eksctl.yaml
kubectl create namespace ecs

#### IMPORTANT NOTE EKS Firewall
will need to enable all VPC sources (192.168.0.0/16) into the EKS cluster
this will need to be done through the console. 
This is probably something that can be added after.. or added to the EKS creation. Could come back to this. 


~/go/bin/istioctl-ecs --context ceposta-eks-3 install -d ~/go/src/github.com/solo-io/istio/manifests -y -f iop.yaml

#### need to expose istiod on load balancer
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml

kubectl apply -f expose.yaml

#### deploy sample apps
should deploy sleep.yaml

kubectl create deployment  echo --image gcr.io/istio-testing/app:latest --port 8080 
kubectl expose deployment echo --port 80 --target-port=8080 



#### deploy task without ztunnel
terraform init
terraform apply -target=module.shell_task


#### deploy task WITH ztunnel
export TF_VAR_ECHO_TOKEN=`~/go/bin/istioctl-ecs bootstrap default`; export TF_VAR_SHELL_TOKEN="${TF_VAR_ECHO_TOKEN}"

terraform apply -target=module.shell_task_ztunnel
terraform apply -target=module.echo_ztunnel_service


#### exec into task
TASK_ID=$(aws ecs list-tasks --cluster ceposta-ecs-ambient --service shell-ztunnel | grep ceposta-ecs-ambient | tr -d '"' | cut -d '/' -f 3)

aws ecs execute-command --cluster ceposta-ecs-ambient --task $TASK_ID --interactive --container shell --command sh



#### Uninstall Istio
istioctl uninstall -y --purge
