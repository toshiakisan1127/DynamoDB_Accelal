terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.10.0"
    }
  }
  backend "s3" {
    bucket         = "catapp-terraform-state-storage"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
