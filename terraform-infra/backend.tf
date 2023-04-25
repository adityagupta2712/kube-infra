terraform {
  backend "s3" {
    bucket         = "terraform-test-aditya"
    dynamodb_table = "terraform-test-locks"
    key            = "aditya/s3/terraform-test.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    profile        = "terraform-aditya"
  }
}
