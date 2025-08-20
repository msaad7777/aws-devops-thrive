# AWS DevOps Thrive Challenge

## 🚀 Overview

This project provisions infrastructure and deploys a containerized Node.js web application on AWS using Terraform, Kubernetes (EKS), and GitHub Actions for CI/CD.

---

## 📦 Project Structure
aws-devops-thrive/
├── app/ # Node.js web app
├── terraform/ # Terraform IAC for AWS resources
├── .github/workflows/ # GitHub Actions CI/CD pipeline
└── README.md # Project documentation


---

## 🛠️ Technologies Used

- **AWS**: EKS, EC2, VPC, IAM, ALB
- **Terraform**: Infrastructure as Code
- **Docker**: App containerization
- **Kubernetes**: Deployment orchestration
- **GitHub Actions**: CI/CD
- **CloudWatch**: Monitoring & logging
- **Route53 / ACM** _(bonus TLS/HTTPS support)_

---

## 📋 Requirements

- Free AWS account
- GitHub account
- Terraform >= 1.5
- Docker
- kubectl
- AWS CLI

---

## ✅ Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/aws-devops-thrive.git
cd aws-devops-thrive


🔁 Replication Instructions (Deploy on Any AWS Account)

This section helps you replicate the entire infrastructure and app deployment using a brand new AWS account with minimal billing.

✅ Prerequisites

Make sure the following are installed on your local machine:

Terraform ≥ 1.5

Docker

kubectl

AWS CLI

Git

🚀 Step-by-Step Setup

Create a new AWS Account

Go to: https://aws.amazon.com/free/

Choose a Free Tier account

Create an IAM user with programmatic access

Go to IAM > Users > Add user

Select:

✅ Programmatic access

✅ AdministratorAccess (for simplicity during replication)

Save Access Key ID and Secret Key

Clone this GitHub repo
git clone https://github.com/msaad7777/aws-devops-thrive.git
cd aws-devops-thrive


aws configure

# Enter the following details:
AWS Access Key ID:     <your key>
AWS Secret Access Key: <your secret>
Default region:        us-east-1
Default output:        json

aws s3api create-bucket --bucket aws-devops-thrive-tfstate --region us-east-1

aws s3api put-bucket-versioning --bucket aws-devops-thrive-tfstate --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5


               ┌──────────────────────────────────────────────────┐
               │                    AWS VPC                       │
               │              (10.0.0.0/16 via module)           │
               │                                                  │
Internet ──►  ALB  ──►  Target Group (HTTP:80, health: /health)   │
   │            │                   │                             │
   │            │                   └────────► ASG (t3.micro)     │
   │            │                                    │            │
   │            │                                    ▼            │
   │            │                         EC2 instances (Amazon   │
   │            │                         Linux 2023, x86_64)     │
   │            │                                    │            │
   │            │                               docker-compose     │
   │            │                                    │            │
   ▼            ▼                         ┌──────────┴──────────┐  │
 http(s)   http(s)                        │   Containers:       │  │
                                          │   - web (Node.js)   │  │
                                          │   - prometheus      │  │
                                          │   - grafana         │  │
                                          │   - node_exporter   │  │
                                          └─────────────────────┘  │
               │                                                  │
               │  CloudWatch Logs & Metrics   SNS (email alerts) │
               └──────────────────────────────────────────────────┘

CI/CD: GitHub Actions → Build & Push to ECR → Terraform plan/apply → ASG instance refresh


What’s Included

VPC (public/private subnets, NAT, IGW) via terraform-aws-modules/vpc.

ECR repo for images.

ALB (HTTP, optional HTTPS with ACM ARN variable).

Target Group with /health checks.

Security Groups for ALB and web tier.

Launch Template (Amazon Linux 2023 x86_64, Docker, docker-compose).

Auto Scaling Group with instance refresh (rolls on LT change).

docker-compose on each instance:

web: Node.js (Hello, World!) listening on 3000, mapped to host 80.

node_exporter on 9100.

prometheus on 9090 (scrapes node_exporter & app placeholder).

grafana on 3000 (dashboarding).

CloudWatch Logs (system & compose log) + basic metrics.

SNS email alerting (high CPU, zero healthy targets).

GitHub Actions pipeline:

Builds Docker image → pushes to ECR → Terraform fmt/init/validate → state reconcile/import → plan/apply → outputs.

Uses unique image tags if you opt to (recommended) or :lates

Prerequisites

AWS account with admin/appropriate permissions.

Remote backend (S3 bucket + DynamoDB lock table) configured in provider.tf (if you’re using remote state).

GitHub secrets (Repo → Settings → Secrets and variables → Actions):

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

(optional) ALERT_EMAIL if you template it in later.

(Local use) Terraform ≥ 1.3, AWS CLI, Docker (only needed to build locally if not using Actions).


app/
index.js # Node.js Hello World + /health
Dockerfile # Node 18, exposes port 3000
docker-compose.yml # host 80 -> container 3000; monitoring stack
prometheus.yml # scrapes node_exporter + app

terraform/
provider.tf # provider + backend + region
variables.tf # project, sizes, docker_image, etc.
outputs.tf # alb_dns_name, app_url, ids
main.tf # VPC module
security.tf # SGs for ALB & web
alb.tf # ALB, TG, listeners
asg.tf # AMI, IAM, LT, ASG, scaling
ecr.tf # ECR repo
.github/workflows/
cicd.yml # CI/CD pipeline


---

## Variables

Key variables in `terraform/variables.tf`:

- `aws_region` (default: `us-east-1`)
- `project_name` (default: `aws-devops-thrive`)
- `docker_image` → overwritten in CI with ECR image
- `ec2_key_pair_name` → if you want SSH
- `min_size`, `max_size`, `desired_capacity`
- `acm_certificate_arn` → for HTTPS
- `alert_email` → for SNS alerts

---

## Deploy via GitHub Actions

1. Push changes to `main`.
2. GitHub Actions pipeline:
   - Logs in to ECR
   - Builds & pushes image
   - Runs Terraform fmt/init/validate
   - Imports/remaps resources
   - Plans & applies
   - Outputs `app_url`

✅ **Access app:**
- App: `http://<alb_dns_name>/` → `Hello, World!`
- Health: `http://<alb_dns_name>/health` → `ok`

If `acm_certificate_arn` set, HTTPS available at port 443.

---

## Deploy Locally (optional)

```bash
cd terraform/
terraform fmt -recursive
terraform init
terraform validate

terraform plan -var="docker_image=<repo>:<tag>" -out=tfplan
terraform apply -auto-approve tfplan
Outputs:

bash
Copy
Edit
terraform output
Monitoring & Logging
Prometheus: http://<instance_ip>:9090

Grafana: http://<instance_ip>:3000

node_exporter: http://<instance_ip>:9100/metrics

Logs in CloudWatch:

/aws/aws-devops-thrive/messages

/aws/aws-devops-thrive/docker

Alarms:

High CPU

Zero healthy targets

SNS sends alerts to your email.

CI/CD Workflow
Imports existing AWS resources to state

Instance refresh on new LT versions

Rollouts happen automatically when Docker image changes

Security & Costs
Restrict SGs in production

Use ACM cert for HTTPS

Never commit .pem files

Costs: ALB, EC2, NAT gateway → minimize with smaller sizes or fewer AZs

Troubleshooting
502 Bad Gateway

Ensure app listens on 3000

ALB health check /health returns 200

Logs: check /docker log group

Image not rolling out

Use unique image tags (e.g., GitHub SHA)

Terraform errors

Run terraform fmt -recursive

Ensure heredocs close correctly

Clean Up
bash
Copy
Edit
cd terraform/
terraform destroy
Next Steps
Add HTTPS with ACM

Restrict monitoring to private subnets

Add Prometheus /metrics in app

Add Blue/Green or Canary

Use Secrets Manager

Add dashboards and alerts on 5xx/latency

Validation Checklist
 Terraform apply successful

 curl http://<alb_dns>/health → ok

 curl http://<alb_dns>/ → Hello, World!

 Logs visible in CloudWatch

 Alerts fire to SNS

 (Optional) Prometheus/Grafana reachable

Reproduce on a Fresh AWS Account
Setup backend (S3 + DynamoDB).

Create repo, add GitHub secrets.

Push code with .github/workflows/cicd.yml.

Wait for Actions → get app_url.

Verify app, monitoring, and alerts.

Destroy with terraform destroy when done.

