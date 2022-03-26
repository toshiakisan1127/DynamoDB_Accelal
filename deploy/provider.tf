terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2"
    }
  }
  backend "s3" {
    bucket = "dax-test-for-sasaki"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
