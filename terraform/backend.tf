terraform {
  backend "s3" {
    bucket         = "terraform-state-aws-webapp"
    key            = "webapp/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}
