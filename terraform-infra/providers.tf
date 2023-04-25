terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "terraform-aditya" //update your user-profile for aws keys
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-test-aditya"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      sse_algorithm = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
 bucket = aws_s3_bucket.terraform-state.id

 block_public_acls       = true
 block_public_policy     = true
 ignore_public_acls      = true
 restrict_public_buckets = true
}

resource "aws_kms_key" "terraform-bucket-key" {
 description             = "This key is used to encrypt bucket objects"
 deletion_window_in_days = 10
 enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
 name          = "alias/terraform-bucket-key"
 target_key_id = aws_kms_key.terraform-bucket-key.key_id
}

resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"
  name = "terraform-test-locks"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  
}