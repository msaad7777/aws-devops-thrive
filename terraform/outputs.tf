# VPC + subnets (unchanged)
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

# ALB + app URL (now the canonical way to reach the app)
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "app_url" {
  value = "http://${aws_lb.app_alb.dns_name}"
}

# Auto Scaling Group
output "asg_name" {
  value = aws_autoscaling_group.app_asg.name
}

# Target group + listeners (handy for debugging / health checks)
output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "listener_http_arn" {
  value = aws_lb_listener.app_listener.arn
}

# Optional HTTPS listener (will be null if you didn't enable ACM)
output "listener_https_arn" {
  value       = try(aws_lb_listener.https[0].arn, null)
  description = "HTTPS listener ARN if ACM was provided; otherwise null."
}

# Security groups
output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

# Monitoring / alerting (if you added the SNS + alarms)
output "sns_alerts_topic_arn" {
  value       = try(aws_sns_topic.alerts.arn, null)
  description = "SNS topic for alerts; null if monitoring.tf not applied."
}

output "cpu_alarm_name" {
  value       = try(aws_cloudwatch_metric_alarm.high_cpu.alarm_name, null)
  description = "High CPU alarm name; null if not created."
}

output "tg_healthy_hosts_alarm_name" {
  value       = try(aws_cloudwatch_metric_alarm.tg_healthy_hosts_zero.alarm_name, null)
  description = "HealthyHostCount alarm name; null if not created."
}
