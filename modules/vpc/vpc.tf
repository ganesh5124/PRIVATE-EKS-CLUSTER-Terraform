# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.cluster_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}



# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}


# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"
  tags = {
    Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  tags = {
    Name = "${var.cluster_name}-nat-gateway-${count.index + 1}"
  }
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = var.allow_all_route
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

# Public route table association
resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


# Create Private Route Tables
resource "aws_route_table" "private_route_table" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = var.allow_all_route
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-route-table-${count.index + 1}"
  }
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}



# Create Security Group for EKS Cluster

locals {
  ports_in = [
    443,
    80,
    22
  ]
  ports_out = [
    80,
    443,
    8080,
  ]
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "${var.cluster_name}-sg-description"
  vpc_id      = aws_vpc.eks_vpc.id
  depends_on  = [aws_vpc.eks_vpc, aws_subnet.public_subnet, aws_subnet.private_subnets]
  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.sg_protocol
      cidr_blocks = [var.allow_all_route]
    }
  }

  dynamic "egress" {
    for_each = toset(local.ports_out)

    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = var.sg_protocol
      cidr_blocks = [var.allow_all_route]
    }
  }

  tags = {
    Name = "${var.cluster_name}-eks-cluster-sg"
  }
}


