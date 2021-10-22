terraform {
  required_version = ">= 0.15.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "saml"
}