resource "aws_instance" "app_server" {
ami = data.aws_ami.amazon_linux.id
instance_type = "t3.micro"
subnet_id = module.vpc.public_subnets[0]
vpc_security_group_ids = [aws_security_group.web_sg.id]
associate_public_ip_address = true
key_name = var.ec2_key_pair_name


user_data = <<-EOF
#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
docker run -d -p 80:80 ${var.docker_image}
EOF


tags = {
Name = "AppEC2"
}
}