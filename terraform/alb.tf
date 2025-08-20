resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = "dev"
  }
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


resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-tg"
    Environment = "dev"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  depends_on = [aws_lb.app_alb, aws_lb_target_group.app_tg]
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}
