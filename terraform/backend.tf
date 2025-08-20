terraform {
  backend "s3" {
    bucket         = "aws-devops-thrive-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
