variable "cluster_name" {}

variable "instance_type" {}

variable "subnet_ids" {}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "security_group_id" {}
