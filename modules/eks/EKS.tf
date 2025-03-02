# Create the EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"
  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  tags = {
    Name        = var.cluster_name
    Environment = "prod"
  }
}

# AddOns for EKS Cluster
resource "aws_eks_addon" "eks-addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = each.value.name
  # addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}


# Create EKS Managed Node Group
resource "aws_eks_node_group" "eks_node_group" {
  node_group_name = "${var.cluster_name}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  cluster_name    = aws_eks_cluster.eks_cluster.name
  subnet_ids      = var.subnet_ids
  instance_types  = [var.instance_type]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  tags = {
    Name        = "${var.cluster_name}-eks-node-group"
    Environment = "dev"
  }

}


