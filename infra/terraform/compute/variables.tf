variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type    = string
  default = "sprintboard"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type    = string
  default = "t3a.small"
}

# Use your EXISTING EC2 key pair name (e.g., "my-mumbai-key")
variable "ssh_key_name" {
  type = string
}
