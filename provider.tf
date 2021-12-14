provider "aws" {
    region = "us-east-1"
    
}

terraform {
  backend "s3" {
    bucket = "mumabucket1"
    key    = "state/terraform.state"
    region = "us-east-1"
  }
}