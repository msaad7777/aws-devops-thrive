variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-devops-thrive"
}variable "aws_region" {
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

# --- Auto Scaling settings ---
variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "ASG minimum capacity"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "ASG maximum capacity"
  type        = number
  default     = 4
}

# --- Monitoring / Alerting ---
variable "alert_email" {
  description = "Email address to subscribe to SNS alerts (CPU, healthy hosts)"
  type        = string
  default     = "you@example.com"
}

# --- Optional HTTPS ---
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS on the ALB (leave empty to disable)"
  type        = string
  default     = ""
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
