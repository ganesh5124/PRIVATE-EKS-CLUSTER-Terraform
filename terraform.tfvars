reagion              = "ap-south-1"
cluster_name         = "my-private-eks-cluster"
vpc_cidr             = "13.0.0.0/16"
public_subnet_cidrs  = ["13.0.10.0/24", "13.0.20.0/24", "13.0.30.0/24"]
private_subnet_cidrs = ["13.0.40.0/24", "13.0.50.0/24", "13.0.60.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
instance_type        = "t2.xlarge"
sg_protocol          = "tcp"
allow_all_route      = "0.0.0.0/0"
addons = [
  {
    name    = "vpc-cni",
    version = "v1.18.1-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.11.1-eksbuild.9"
  },
  {
    name    = "kube-proxy"
    version = "v1.29.3-eksbuild.2"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.30.0-eksbuild.1"
  }
  # Add more addons as needed
]
