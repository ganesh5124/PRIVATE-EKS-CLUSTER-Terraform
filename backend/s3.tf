
provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-lock55"
  tags = {
    Name        = "terraform-state-bucket"
    Environment = "prod"
  }
    lifecycle {
    prevent_destroy = false
  }
}



resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

