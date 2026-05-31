#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -ex

echo "Updating system..."
apt-get update -y && apt-get upgrade -y

echo "Installing Docker..."
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Installing Python3 and pip..."
apt-get install -y python3 python3-pip

echo "Creating app directory"
mkdir -p /home/ubuntu/cloudguard-app
chown ubuntu:ubuntu /home/ubuntu/cloudguard-app

echo "User data completed"
