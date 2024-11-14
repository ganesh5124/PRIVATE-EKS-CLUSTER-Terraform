### Creating Private EKS CLUSTER

Prerequisites

- AWS CLI ( use access and scret key) and kubectl installed and configured.
- Terraform CLI installed.
- AWS IAM user with permissions for EKS, VPC, and IAM services.

terraform configuration

- Create Terraform backend to store state file. Please refer to main.tf
- Please change bucket name according to your bucket


Steps to create Private EKS CLUSTER

- Step up VPC and Subnets 
- Create Security Groups 
- Create IAM Roles and Policies refer rolesandPolicies.tf
- Deploy the EKS Cluster refer to EKS.tf
- Configure EKS Node Group refer to EKS.tf
- Outputs and Access 

Apply the configuration

- terraform init
- terraform plan
- terraform apply

to destroy the create resources use terraform destroy

Test the Configuration
- to test the configuration we need bastion host on public subnet
- aws eks --region ap-south-1 update-kubeconfig --name private-eks-cluster
- kubectl get nodes

