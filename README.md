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
