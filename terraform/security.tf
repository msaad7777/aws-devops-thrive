resource "aws_security_group" "web_sg" {
name = "${var.project_name}-web-sg"
description = "Allow HTTP"
vpc_id = module.vpc.vpc_id

ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb_sg.id]
}



egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_security_group" "alb_sg" {
name        = "${var.project_name}-alb-sg"
description = "Allow HTTP to ALB"
vpc_id = module.vpc.vpc_id


ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}


egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}