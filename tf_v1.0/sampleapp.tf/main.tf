# Backend setup
terraform {
  backend "s3" {
    key = "sampleapp.tfstate"
  }
}

# Variable definitions
variable "region" {
  default = "us-east-1"
}

# Provider and access setup
provider "aws" {
  version = "~> 2.0"
  region = "${var.region}"
}


