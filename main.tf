
module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  instance_type = var.instance_type
  subnet_ids = module.vpc.private_subnet_ids
  security_group_id = module.vpc.security_group_id
  addons = var.addons
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  allow_all_route = var.allow_all_route
  sg_protocol = var.sg_protocol
  cluster_name = var.cluster_name
  private_subnet_cidrs = var.private_subnet_cidrs
}