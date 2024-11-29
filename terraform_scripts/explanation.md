## Objective:
This terraform scripts was created to automate the deployment of a three tier application to multi eks clusters using ArgoCD and helm. 
The article below explains the manual process:
[Deploying Microservices Across Multiple Clusters with GitOps and Helm: A Step-by-Step Guide.](https://medium.com/@nyerhovwoonitcha/deploying-microservices-across-multiple-clusters-with-gitops-and-helm-a-step-by-step-guide-9a194f8c822a)

## Steps.
To understand this, begin reading from the `variables.tf` file. This file deines a variable called `clusters`, which is a map of objects. Each object in this map represents a cluster and includes attributes that define the configuration for that cluster. Specifically, it defines the attributes for three clusters:  
cluster1, cluster2 , and  cluster3. Each of these clusters has attributes like  cluster_name ,  cluster_version , private_subnets, public_subnets, and vpc_cidr 


Proceed to the `vpc.tf` file, this files uses the `for each` function to create 3 VPCs for each cluster.

The `ebs_sci.tf` file adds the ebs_csi controller to the clusters to provision volumes to be used to fulfill PVC requirements. This will be especially useful in cluster 2 and 3 where redis will be deployed.

Next is the `eks.tf` file, this file creates 3 eks clusters using the values defined for each cluster in the `variables.tf` file. The 3 clusters are created with some peculiarities in mind. Cluster 1 is created in a public subnet.
**Cluster 1**
- Argo CD will be installed in Cluster1.
- The Hubspoke model of ArgoCD will be used so cluster 2 and 3 will be added to and monitored by ArgoCD 
- The ArgoCD will be accessed through NodePort service hence, ingress will not be deployed in cluster1

**Cluster  2 and 3**
- The 3 tier application will be deployed in cluster 2 and 3.
- The app will be accessed via Ingress, hence will be deployed in cluster 2 and 3

The CLI commands for installing EKS AWS Loadbalancer is as follows
Step 1: Download the policy
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```
Step 2: Create the policy
```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```
Step 3: Create IAM role
```
eksctl create iamserviceaccount \
  --cluster=three-tier-app-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::503561420107:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```
Stwp 4: Add and update the repo
```
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks
```

Step 5: Install the eks aws lb
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \            
  -n kube-system \
  --set clusterName=three-tier-app-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=eu-north-1 \
  --set vpcId=vpc-09a35df8f6a64e045
```

You can see the process involves: First downloading the Json policy, creating the policy in the aws account, creating an IAM role for the AWS EKS LB, the policy is attached to the role and a service account is also created. This service account is for the cluster where the ALB LB will be deployed. Finally the EKS AWS helm repo is installed and the LB is deployed.

These steps are to be automated using terraform and that is what was done in the `iam.tf` and `helm_release.tf` file. In the iam.tf file, the role is created and the policy is attached. The policy should be already created in the account. The service account is also created. 
In the `helm_release.tf`, eks aws lb is deployed. 
The same step is repeated for the ebs_csi plugin. To understand why these steps are done, read the article [Deploying 3 tier application on eks using helm](https://medium.com/@nyerhovwoonitcha/deploying-a-three-tier-architecture-microservices-e-commerce-application-to-eks-using-helm-8463cd25e6c6)

Finally ArgoCD is installed in cluster one, first the namespace is created and using helm ArgoCD is deployed.

Security group.tf is defines the security group for the clusters. The security group for cluster1 allows traffic to the NodePort range since ArgoCD deployed in the cluster will be accessed via NodePort service. The security groups for CLuster 2 and 3 allows traffic to ports 80 and 443 for Ingress.

**IN A NUTSHELL**
### EKS CLUSTERS
- 3 EKS clusters will be created.
### VPS's
- Separate VPC's will be created for each cluster with specified CIDR blocks, private subnets, and public subnets.
### EBS CSI Driver:
- The EBS CSI driver addon will be installed in all three EKS clusters.
- IAM role with OIDC for theEBS CSI driver addon will be created. Necessary IAM policies will be attached to these roles.
- Service accounts for the AWS Load Balancer Controller will be created with the appropriate IAM role annotations
### ArgoCD:
- ArgoCD will be deployed in cluster 1 in the ArgoCD namespace using helm. This is the hubspoke cluster.
- The security group of cluster 1 will allow traffice to the NodePort Range. This is because ArgoCD UI will be accessed via NodePort service.
### AWS Load Balancer Controller:
- aws lb controller will be deployed in cluster 2 and 3 using helm. This is because the application will be accessed via ingress.
- IAM role with OIDC for the AWS Load Balancer Controller will be created. Necessary IAM policies will be attached to these roles.
- Service accounts for the AWS Load Balancer Controller will be created with the appropriate IAM role annotations

**The Output.tf**
- Cluster Names: Names of the EKS clusters.
- VPC IDs: IDs of the VPCs for each cluster.
- Private Subnets: Private subnets for each VPC.
-Public Subnets: Public subnets for each VPC.
- OIDC Provider URLs: OIDC provider URLs for each cluster.
- Service Account ARNs: ARNs of the service accounts for the AWS Load Balancer Controller and EBS CSI driver.
- Helm Release Names: Names of the Helm releases for the AWS Load Balancer Controller and ArgoCD.
- ArgoCD Namespace: Name of the ArgoCD namespace.