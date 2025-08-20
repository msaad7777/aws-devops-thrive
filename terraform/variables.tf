variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "aws-devops-thrive"
}

variable "ec2_key_pair_name" {
  description = "EC2 key pair name for SSH access to instances"
  type        = string
  default     = "aws-devops-thrive-key"
}

variable "docker_image" {
  description = "Container image to deploy (overridden by CI/CD)"
  type        = string
  default     = "msaad7777/aws-devops-thrive:latest"
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "ASG minimum capacity"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "ASG maximum capacity"
  type        = number
  default     = 4
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
  default     = "you@example.com"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS on the ALB (leave empty to disable)"
  type        = string
  default     = ""
}
