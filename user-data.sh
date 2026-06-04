#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -ex

echo "Updating system..."
apt-get update -y && apt-get upgrade -y

echo "Installing prerequisites..."
apt-get install -y unzip curl python3 python3-pip

echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

echo "Installing Docker..."
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Creating app directory"
mkdir -p /home/ubuntu/cloudguard-app/app
chown ubuntu:ubuntu /home/ubuntu/cloudguard-app/app

echo "Fetching Grafana admin password from Secrets Manager..."
SECRET_NAME=${secret_name}
REGION=${aws_region}

GF_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query SecretString --output text)

echo "GF_SECURITY_ADMIN_PASSWORD=$GF_PASSWORD" > /home/ubuntu/cloudguard-app/app/grafana.env
chown ubuntu:ubuntu /home/ubuntu/cloudguard-app/app/grafana.env

echo "User data completed"
