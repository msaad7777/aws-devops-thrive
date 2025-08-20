########################################
# AMI (Amazon Linux 2023, x86_64)
########################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

########################################
# IAM for EC2 -> ECR (pull) + CloudWatch Agent
########################################
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# CloudWatch log groups (bootstrap + compose logs)
resource "aws_cloudwatch_log_group" "cloud_init" {
  name              = "/aws/${var.project_name}/cloud-init"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "user_data" {
  name              = "/aws/${var.project_name}/user-data"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "docker" {
  name              = "/aws/${var.project_name}/docker"
  retention_in_days = 14
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

########################################
# Launch Template
########################################
resource "aws_launch_template" "app_lt" {
  name_prefix            = "${var.project_name}-lt-"
  update_default_version = true

  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOT
#!/bin/bash
set -euxo pipefail


exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "[user-data] Starting bootstrap at $(date)"

export AWS_DEFAULT_REGION="${var.aws_region}"
export PROJECT_NAME="${var.project_name}"


dnf -y update
dnf -y install docker jq awscli curl

systemctl enable --now docker
usermod -aG docker ec2-user || true


echo "[user-data] Installing docker-compose"
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version || true


if [[ "${var.docker_image}" == *.amazonaws.com* ]]; then
  echo "[user-data] ECR login"
  aws ecr get-login-password --region "$AWS_DEFAULT_REGION" | docker login --username AWS --password-stdin "$(echo "${var.docker_image}" | awk -F/ '{print $1}')"
fi


cat >/home/ec2-user/docker-compose.yml <<'YML'
version: "3.8"
services:
  web:
    image: "__IMAGE__"
    ports:
      - "80:3000"         # instance:80 -> container:3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  node_exporter:
    image: prom/node-exporter
    container_name: node_exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - /home/ec2-user/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    restart: unless-stopped

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    restart: unless-stopped
YML


cat >/home/ec2-user/prometheus.yml <<'PROM'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'app'
    metrics_path: /health
    static_configs:
      - targets: ['localhost:3000']
PROM


sed -i 's#__IMAGE__#${var.docker_image}#g' /home/ec2-user/docker-compose.yml

chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml /home/ec2-user/prometheus.yml


echo "[user-data] docker-compose up -d"
cd /home/ec2-user
docker-compose up -d > /var/log/docker-compose.log 2>&1 || true


echo "[user-data] Installing CloudWatch Agent"
dnf -y install amazon-cloudwatch-agent

  cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<JSON
  {
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            { "file_path": "/var/log/cloud-init-output.log", "log_group_name": "/aws/${var.project_name}/cloud-init", "log_stream_name": "{instance_id}" },
            { "file_path": "/var/log/user-data.log",          "log_group_name": "/aws/${var.project_name}/user-data",  "log_stream_name": "{instance_id}" },
            { "file_path": "/var/log/docker-compose.log",     "log_group_name": "/aws/${var.project_name}/docker",     "log_stream_name": "{instance_id}" }
          ]
        }
      }
    },
    "metrics": {
      "namespace": "DevOpsThrive/EC2",
      "append_dimensions": { "InstanceId": "$${aws:InstanceId}" },
      "metrics_collected": {
        "cpu": { "measurement": ["cpu_usage_idle","cpu_usage_user","cpu_usage_system"], "metrics_collection_interval": 60 },
        "mem": { "measurement": ["mem_used_percent"], "metrics_collection_interval": 60 }
      }
    }
  }
  JSON

  systemctl enable --now amazon-cloudwatch-agent
echo "[user-data] Bootstrap complete at $(date)"
EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ec2"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Auto Scaling Group + Target Tracking + Instance Refresh
########################################
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project_name}-asg"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Use private subnets (instances get internet via NAT)
  vpc_zone_identifier = module.vpc.private_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 120

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ec2"
    propagate_at_launch = true
  }

  # Roll instances when Launch Template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 60
    }
    triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scale on ALB requests per target (~100 reqs/instance)
resource "aws_autoscaling_policy" "req_per_target" {
  name                   = "${var.project_name}-tt-requests"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.app_alb.arn_suffix}/${aws_lb_target_group.app_tg.arn_suffix}"
    }
    target_value = 100
  }
}
