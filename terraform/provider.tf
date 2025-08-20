terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"

  # keep your backend "s3" block here if you already have one
  # backend "s3" {
  #   bucket = "your-bucket"
  #   key    = "your/key.tfstate"
  #   region = "us-east-1"
  #   dynamodb_table = "your-lock-table"
  # }
}

provider "aws" {
  region = var.aws_region
}

/* REMOVED: duplicate AMI data source.
data "aws_ami" "amazon_linux" { ... }
*/
