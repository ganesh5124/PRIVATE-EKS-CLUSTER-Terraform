
# Create the EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"
  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    subnet_ids              = aws_subnet.private_subnets[*].id
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access = false
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  tags = {
    Name        = var.cluster_name
    Environment = "prod"
  }
}

resource "aws_eks_addon" "eks_addon1" {
  for_each     = toset(var.addons)
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = each.key
}


# Create EKS Managed Node Group
resource "aws_eks_node_group" "eks_node_group" {
  node_group_name = "${var.cluster_name}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  cluster_name    = aws_eks_cluster.eks_cluster.name
  subnet_ids      = aws_subnet.private_subnets[*].id
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

