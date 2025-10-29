terraform {
  backend "s3" {
    bucket         = "sprintboard-dev-tfstate-q47b5s"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sprintboard-dev-tflock"
    encrypt        = true
  }
}
