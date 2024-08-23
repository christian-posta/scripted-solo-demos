

Setting up the cluster:

source env.sh
eksctl create cluster --name $CLUSTER_NAME1 --region $AWS_REGION


### Configure the EKS nodes' security group to receive traffic from the VPC Lattice network.
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --output json| jq -r '.cluster.resourcesVpcConfig.clusterSecurityGroupId')

PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists --query "PrefixLists[?PrefixListName=="\'com.amazonaws.$AWS_REGION.vpc-lattice\'"].PrefixListId" | jq -r '.[]')

aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --ip-permissions "PrefixListIds=[{PrefixListId=${PREFIX_LIST_ID}}],IpProtocol=-1"

PREFIX_LIST_ID_IPV6=$(aws ec2 describe-managed-prefix-lists --query "PrefixLists[?PrefixListName=="\'com.amazonaws.$AWS_REGION.ipv6.vpc-lattice\'"].PrefixListId" | jq -r '.[]')

aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --ip-permissions "PrefixListIds=[{PrefixListId=${PREFIX_LIST_ID_IPV6}}],IpProtocol=-1"

### Set up permissions to allow the Gateway API controller to operate

curl https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/files/controller-installation/recommended-inline-policy.json  -o recommended-inline-policy.json

aws iam create-policy \
    --policy-name VPCLatticeControllerIAMPolicy \
    --policy-document file://recommended-inline-policy.json

export VPCLatticeControllerIAMPolicyArn=$(aws iam list-policies --query 'Policies[?PolicyName==`VPCLatticeControllerIAMPolicy`].Arn' --output text)

curl https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/files/controller-installation/deploy-namesystem.yaml  -o deploy-namesystem.yaml

kubectl apply -f deploy-namesystem.yaml


### Add pod identities

aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name eks-pod-identity-agent --addon-version v1.0.0-eksbuild.1

kubectl get pods -n kube-system | grep 'eks-pod-identity-agent'


### Set up mapping between SA and roles
cat >gateway-api-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
    name: gateway-api-controller
    namespace: aws-application-networking-system
EOF
kubectl apply -f gateway-api-controller-service-account.yaml

cat >trust-relationship.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEksAuthToAssumeRoleForPodIdentity",
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}
EOF

aws iam create-role --role-name VPCLatticeControllerIAMRole --assume-role-policy-document file://trust-relationship.json --description "IAM Role for AWS Gateway API Controller for VPC Lattice"

aws iam attach-role-policy --role-name VPCLatticeControllerIAMRole --policy-arn=$VPCLatticeControllerIAMPolicyArn

export VPCLatticeControllerIAMRoleArn=$(aws iam list-roles --query 'Roles[?RoleName==`VPCLatticeControllerIAMRole`].Arn' --output text)


##### create the association

aws eks create-pod-identity-association --cluster-name $CLUSTER_NAME --role-arn $VPCLatticeControllerIAMRoleArn --namespace aws-application-networking-system --service-account gateway-api-controller



### Now create the gateway controller

# login to ECR
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
# Run helm with either install or upgrade
helm install gateway-api-controller \
    oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
    --version=v1.0.6 \
    --set=serviceAccount.create=false \
    --namespace aws-application-networking-system \
    --set=log.level=info 


curl https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/files/controller-installation/gatewayclass.yaml  -o gatewayclass.yaml

kubectl apply -f gatewayclass.yaml


# Install the Sample apps Cluster 1


aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

helm upgrade gateway-api-controller \
oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
--version=v1.0.6 \
--reuse-values \
--namespace aws-application-networking-system \
--set=defaultServiceNetwork=my-hotel


export SAMPLE_DIR=/home/solo/dev/aws/aws-application-networking-k8s

kubectl apply -f $SAMPLE_DIR/files/examples/my-hotel-gateway.yaml

We can update the exact file location following the pattern above, or just move the files into the dir here


kubectl apply -f files/examples/parking.yaml
kubectl apply -f files/examples/review.yaml
kubectl apply -f files/examples/rate-route-path.yaml
kubectl apply -f files/examples/inventory-ver1.yaml
kubectl apply -f files/examples/inventory-route.yaml


kubectl get httproute


### store VPC lattice DNS names to variables
ratesFQDN=$(kubectl get httproute rates -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')

inventoryFQDN=$(kubectl get httproute inventory -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')


### check connectivity using lattice DNS names
kubectl exec deploy/inventory-ver1 -- curl -s $ratesFQDN/parking $ratesFQDN/review

kubectl exec deploy/parking -- curl -s $inventoryFQDN



# Install to cluster 2

aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

helm upgrade gateway-api-controller \
oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
--version=v1.0.6 \
--reuse-values \
--namespace aws-application-networking-system \
--set=defaultServiceNetwork=my-hotel

kubectl apply -f $SAMPLE_DIR/files/examples/my-hotel-gateway.yaml

kubectl get gateway

kubectl apply -f files/examples/inventory-ver2.yaml

kubectl --context ceposta-eks-2 apply -f files/examples/inventory-ver2-export.yaml

##### switch back to the first cluster:


#### need to import the inventory v2 service
kubectl --context ceposta-eks-1 apply -f files/examples/inventory-ver2-import.yaml

##### let's put the routing weights to 90% going to v2
kubectl --context ceposta-eks-1 apply -f files/examples/inventory-route-bluegreen.yaml


#### from the first cluster let's call inventory



inventoryFQDN=$(kubectl --context ceposta-eks-1 get httproute inventory -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')

kubectl --context ceposta-eks-1 exec deploy/parking -- sh -c 'for ((i=1; i<=30; i++)); do curl -s "$0"; done' "$inventoryFQDN"



