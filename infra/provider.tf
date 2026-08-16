terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # # Pin to AWS provider 5.x — allows 5.x updates but blocks 6.0, so a future major release can't silently break this config
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}