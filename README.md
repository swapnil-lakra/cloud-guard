# CloudGuard – Automated AWS Security & Cost Optimizer

CloudGuard is a serverless-first Cloud Security Posture Management (CSPM) and FinOps tool that continuously scans an AWS account for security misconfigurations and cost-saving opportunities, visualizes findings on a real-time dashboard, and sends alerts.

## 🔧 Features

- **Security Scanning:** Public S3 buckets, open security groups, IAM users without MFA.
- **Cost Optimization:** Unused EBS volumes, old snapshots, idle EC2 instances with estimated monthly savings.
- **Real-time Dashboard:** Grafana dashboards with Prometheus metrics (security findings count, total savings).
- **Alerting:** SNS email alerts for high-severity findings.
- **Infrastructure as Code:** Entire stack defined in Terraform, remote state with locking.
- **Secrets Management:** Grafana password stored in AWS Secrets Manager, KMS encryption for sensitive data.
- **Least Privilege IAM:** Custom IAM roles with resource-level permissions.

## 🏗️ Architecture

[Internet]
    |
    v
[Application Load Balancer] (HTTP :80)
    |
    v
[Target Group :5000] --> [EC2 Instance (t2.micro)]
                             |
                             | Docker Containers:
                             | - Flask API (Python)
                             | - Prometheus
                             | - Grafana
                             | (Secrets Manager for Grafana password)
                             |
                             | IAM Role: DynamoDB read, Secrets Manager read
                             v
                         [DynamoDB Table: cloudguard-findings]
                             ^
                             | (writes)
                             |
[AWS Lambda (scanner)]        |
  - Python Boto3              |
  - Hourly CloudWatch Event   |
  - Env vars encrypted (KMS)  |
  - IAM Role: S3, EC2, IAM, DynamoDB, SNS, CloudWatch, KMS
                             |
                             v
                         [SNS Topic] --> Email (alert)
                         
[VPC: 10.0.0.0/16]
  - 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
  - Internet Gateway
  - Security Groups (EC2, ALB)
  
[KMS Key] <-- encrypts Lambda env, S3 state bucket
[Secrets Manager] <-- Grafana admin password
[S3 bucket] <-- Terraform remote state (encrypted, versioned)

## 🚀 Tech Stack

- **Cloud:** AWS (Lambda, DynamoDB, EC2, ALB, SNS, S3, KMS, Secrets Manager)
- **IaC:** Terraform (remote state S3 + DynamoDB lock)
- **Backend:** Python (Flask, Boto3)
- **Containerization:** Docker, Docker Compose
- **Monitoring:** Prometheus, Grafana
- **CI/CD (optional):** GitHub Actions (planned)

## 📈 Key Metrics

- Findings tracked: 3 security checks + 3 cost checks
- Estimated monthly savings calculated per resource
- Dashboard with real-time metrics

## 📚 Skills Demonstrated

1. Linux & OS Fundamentals
2. Networking (VPC, ALB, Security Groups)
3. Cloud Security & IAM (least privilege, KMS, Secrets Manager)
4. Infrastructure as Code (Terraform, remote state, idempotency)
5. Scripting & Automation (Python/Boto3)
6. Monitoring & Observability (Prometheus, Grafana, logs)
7. FinOps / Cloud Cost Optimization
8. Troubleshooting & Problem Solving (simulated RCA scenarios)

## 🛠️ How to Deploy

1. Clone repo.
2. Configure AWS CLI profile `cloudguard`.
3. Fill `terraform.tfvars` with your `key_name`, `my_ip`, `alert_email`.
4. `terraform init` & `terraform apply`.
5. Wait for EC2 userdata, then SSH to instance and run `docker-compose up -d` in `app/` directory.
6. Invoke Lambda manually to see findings, open Grafana dashboard.

## ⚠️ Cleanup

To avoid ongoing costs, run `terraform destroy` after use. Ensure S3 state bucket and DynamoDB lock table are also deleted manually if desired.
