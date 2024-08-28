
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
~/go/bin/istioctl-ecs bootstrap default

export TF_VAR_ECHO_TOKEN=`~/go/bin/istioctl-ecs bootstrap default`; export TF_VAR_SHELL_TOKEN="${TF_VAR_ECHO_TOKEN}"

terraform apply -target=module.shell_task_ztunnel
terraform apply -target=module.echo_ztunnel_service


#### exec into task
TASK_ID=$(aws ecs list-tasks --cluster ceposta-ecs-ambient --service shell-ztunnel | grep ceposta-ecs-ambient | tr -d '"' | cut -d '/' -f 3)

aws ecs execute-command --cluster ceposta-ecs-ambient --task $TASK_ID --interactive --container shell --command sh


Calling:

# public
ALL_PROXY=socks5h://127.0.0.1:15080 curl httpbin.org/get

# Kubernetes pod
ALL_PROXY=socks5h://127.0.0.1:15080 curl echo.default
ALL_PROXY=socks5h://127.0.0.1:15080 curl httpbin.default:8080

# To ECS task with ztunnel (hbone)
ALL_PROXY=socks5h://127.0.0.1:15080 curl echo-ztunnel.ecs.local:8080 -v



#### Uninstall Istio
istioctl uninstall -y --purge



### Lambda

Connect the lambda to the same VPC as the EKS cluster

add this ENV variable:

BOOTSTRAP_TOKEN
using: ~/go/bin/istioctl-ecs bootstrap default

Use this image: 

606469916935.dkr.ecr.us-east-2.amazonaws.com/ceposta:echo-lambda-10 

If you cannot add to a VPC on first creation, go find this policy `AWSLambdaVPCAccessExecutionRole` and add it to our lambda


aws lambda invoke --function-name ceposta-echo-ztunnel-vpc /dev/stdout --payload '{"url":"http://echo-ztunnel.ecs.local:8080"}' --cli-binary-format raw-in-base64-out

aws lambda invoke --function-name ceposta-echo-ztunnel-vpc /dev/stdout --payload '{"url":"http://httpbin.default:8080/headers"}' --cli-binary-format raw-in-base64-out