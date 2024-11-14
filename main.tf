
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.1"
    }
  }
  backend "s3" {
    bucket  = "bucketfordemopurpose"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
