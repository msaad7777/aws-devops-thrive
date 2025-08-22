resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
  idle_timeout       = 60

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-tg"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  port     = 80 # matches host port from compose: "80:3000"
  protocol = "HTTP"

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/" # <— change from "/health" to "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
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
}

# Optional HTTPS (requires var.acm_certificate_arn != "")
resource "aws_lb_listener" "https" {
  count             = var.acm_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
