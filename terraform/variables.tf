variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-devops-thrive"
}

variable "ec2_key_pair_name" {
  description = "EC2 key pair name for SSH"
  type        = string
  default     = "aws-devops-thrive-key"
}

variable "docker_image" {
  description = "Docker image to deploy on EC2"
  type        = string
  default     = "msaad7777/aws-devops-thrive:latest"
}
