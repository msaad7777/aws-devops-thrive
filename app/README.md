# Hello World Node.js App

This is a simple "Hello, World!" app containerized using Docker and deployed via Terraform to AWS EC2.

## To Build Locally

```bash
docker build -t msaad7777/aws-devops-thrive:latest .
docker run -p 80:80 msaad7777/aws-devops-thrive:latest
