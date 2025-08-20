resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ec2_key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
              
              yum install -y git
              git clone https://github.com/msaad7777/aws-devops-thrive.git /home/ec2-user/app

              cd /home/ec2-user/app/app
              
              echo "DOCKER_IMAGE=${var.docker_image}" > .env

              docker-compose up -d --build
              EOF

  tags = {
    Name = "AppEC2"
  }

  depends_on = [aws_security_group.web_sg]
}
