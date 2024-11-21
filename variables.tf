variable "cluster_name" {}

variable "vpc_cidr" {}

variable "private_subnet_cidrs" {}

variable "instance_type" {}

variable "public_subnet_cidrs" {}

variable "availability_zones" {}


variable "sg_protocol" {}

variable "allow_all_route" {}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
