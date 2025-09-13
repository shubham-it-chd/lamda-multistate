terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-multistate"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
