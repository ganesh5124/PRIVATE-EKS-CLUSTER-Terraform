terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.1"
    }
  }
  backend "s3" {
    bucket  = "terraform-state-bucket-lock54"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region  = var.reagion
  alias   = "ap-south"
  profile = "default"
}

