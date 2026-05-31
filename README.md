# CloudGuard – Automated AWS Security & Cost Optimizer

## Overview

CloudGuard is an AWS-native security and cost optimization platform designed to help organizations continuously monitor their cloud environments for security misconfigurations and unnecessary spending.

Modern AWS environments often contain hundreds of resources spread across multiple services. Identifying security risks such as public S3 buckets, overly permissive security groups, missing MFA enforcement, and unencrypted resources can be challenging. At the same time, cloud costs can rapidly increase due to idle compute instances, unattached storage volumes, and outdated snapshots.

CloudGuard automates this process by scanning AWS resources, generating actionable findings, calculating a security posture score, identifying cost-saving opportunities, and visualizing insights through an interactive dashboard.

This project combines the concepts of:

* Cloud Security Posture Management (CSPM)
* FinOps & Cloud Cost Optimization
* Infrastructure as Code (IaC)
* Monitoring & Observability
* Cloud Automation

---

## Business Problem

Organizations often struggle with:

### Security Challenges

* Publicly accessible S3 buckets
* Security groups exposing sensitive ports
* IAM users without MFA enabled
* Overly permissive IAM policies
* Unencrypted storage resources
* Poor visibility into security posture

### Cost Optimization Challenges

* Idle EC2 instances
* Unattached EBS volumes
* Unused Elastic IP addresses
* Outdated snapshots
* Overprovisioned resources
* Lack of cost visibility

Manual audits are time-consuming, error-prone, and difficult to scale.

CloudGuard provides an automated solution to continuously detect these issues and recommend corrective actions.

---

## Key Features

### Security Assessment

* Detect public S3 buckets
* Identify open security groups
* Check IAM MFA compliance
* Verify encryption settings
* Analyze IAM policy risks
* Generate overall security score

### Cost Optimization

* Detect idle EC2 instances
* Identify unattached EBS volumes
* Find unused snapshots
* Highlight underutilized resources
* Generate cost-saving recommendations
* Estimate monthly savings

### Monitoring & Alerting

* CloudWatch logging
* SNS email notifications
* Prometheus metrics collection
* Grafana dashboards
* Infrastructure health monitoring

### Automation

* Scheduled AWS account scans
* Automated finding collection
* Real-time dashboard updates
* Infrastructure deployment using Terraform

---

## Architecture

### Core Components

#### AWS Lambda (Python)

Responsible for:

* Security scans
* Cost analysis
* AWS API interactions via Boto3
* Scheduled account assessments

#### DynamoDB

Stores:

* Scan findings
* Security results
* Cost recommendations
* Historical scan data

#### EC2 (t2.micro)

Hosts:

* Flask API
* Prometheus
* Grafana

#### SNS

Responsible for:

* Email alerts
* Critical security notifications

#### CloudWatch

Provides:

* Application logs
* Metrics
* Alarms
* Monitoring

#### Secrets Manager

Stores:

* Sensitive credentials
* API secrets
* Configuration values

---

## Infrastructure Architecture

### VPC Design

Custom VPC with:

* Internet Gateway
* 2 Public Subnets across multiple Availability Zones
* Route Tables
* Application Load Balancer
* EC2 Instance
* Security Groups

### Network Flow

Internet User
↓
Application Load Balancer
↓
Flask API (EC2)
↓
DynamoDB
↓
Dashboard

AWS Lambda
↓
AWS Account Scan
↓
DynamoDB Findings
↓
SNS Alerts

---

## Technology Stack

### Cloud Platform

* AWS

### Infrastructure as Code

* Terraform

### Programming

* Python 3.9
* Bash

### Backend

* Flask

### Monitoring

* Prometheus
* Grafana
* CloudWatch

### Database

* DynamoDB

### Storage

* Amazon S3

### Security

* IAM
* AWS KMS
* Secrets Manager

---

## Skills Demonstrated

### Linux & Operating Systems

* EC2 administration
* Systemd services
* Cron jobs
* Process management
* File permissions

### Networking

* VPC design
* Subnets
* Route tables
* Security groups
* Load balancing

### Cloud Security

* IAM roles
* Least privilege access
* S3 policies
* Encryption
* Secrets management

### Infrastructure as Code

* Terraform modules
* Remote state management
* Infrastructure automation

### Scripting & Automation

* Python automation
* AWS SDK (Boto3)
* Error handling
* Scheduled workflows

### Monitoring & Observability

* Metrics collection
* Dashboards
* Logging
* Alerting

### FinOps

* Resource utilization analysis
* Cost optimization
* Rightsizing recommendations
* Waste detection

### Troubleshooting

* Incident investigation
* Root cause analysis
* Cloud debugging
* Infrastructure diagnostics

---

## Example Findings

### Security Finding

Risk: Public S3 Bucket Detected

Severity: High

Recommendation:

* Disable public access
* Enable bucket encryption
* Apply least-privilege bucket policy

### Cost Finding

Resource: Idle EC2 Instance

Monthly Cost: $18

Recommendation:

* Stop or terminate instance
* Consider Auto Scaling

Estimated Savings: $216/year

---

## Future Enhancements

* Multi-account AWS support
* AWS Organizations integration
* CIS Benchmark compliance checks
* Automated remediation workflows
* Slack and Microsoft Teams alerts
* AI-powered risk prioritization
* Cost forecasting and budgeting
* Kubernetes (EKS) scanning

---

## Learning Outcomes

By building CloudGuard, engineers gain hands-on experience in:

* AWS Architecture
* Cloud Security
* FinOps
* Infrastructure as Code
* Monitoring & Observability
* Python Automation
* Incident Response
* Production-Grade Cloud Operations

---

## Disclaimer

CloudGuard is an educational and portfolio project designed to demonstrate real-world Cloud Security, FinOps, Infrastructure Automation, and AWS Engineering practices.
