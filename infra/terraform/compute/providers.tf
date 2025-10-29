terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket         = "sprintboard-dev-tfstate-q47b5s"
    key            = "compute/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sprintboard-dev-tflock"
    encrypt        = true
  }
}
provider "aws" { region = var.aws_region }
