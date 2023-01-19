terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.30.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~>2.3.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Region     = var.region
      Project    = var.project
      Env        = var.env
      Zone       = local.zone
      DeployedBy = "Terraform"
    }
  }
}