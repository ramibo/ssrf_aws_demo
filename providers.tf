terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    #   version = "~> 4.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "aws_ssrf_demo"
}