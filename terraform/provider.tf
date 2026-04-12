terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "tf-backend-390403882388-eu-west-1"
    key    = "my-sample-kubernetes-app.tfstate"
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "Dev"
      Name        = "Sample"
      auto-delete = "2 months"
    }
  }
}

provider "awscc" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
