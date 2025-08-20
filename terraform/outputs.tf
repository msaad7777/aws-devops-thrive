output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}


output "ec2_public_ip" {
value = aws_instance.app_server.public_ip
}


output "alb_dns" {
value = aws_lb.app_alb.dns_name
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}