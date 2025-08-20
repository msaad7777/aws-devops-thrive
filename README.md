# AWS DevOps Thrive Challenge

## 🚀 Overview

This project provisions infrastructure and deploys a containerized Node.js web application on AWS using Terraform, Kubernetes (EKS), and GitHub Actions for CI/CD.

---

## 📦 Project Structure
aws-devops-thrive/
├── app/ # Node.js web app
├── terraform/ # Terraform IAC for AWS resources
├── k8s/ # Kubernetes manifests
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

# Enter the following:
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

