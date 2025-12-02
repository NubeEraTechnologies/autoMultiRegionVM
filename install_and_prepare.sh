#!/bin/bash
set -e

echo "==============================="
echo " Updating system packages"
echo "==============================="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "==============================="
echo " Installing required utilities"
echo "==============================="
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates

echo "==============================="
echo " Installing Azure CLI"
echo "==============================="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "==============================="
echo " Installing Terraform"
echo "==============================="
# Add Hashicorp Repo
sudo wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y
sudo apt-get install terraform -y

echo "==============================="
echo " Checking Terraform version"
echo "==============================="
terraform -version

echo "==============================="
echo " Generating SSH Keys (if not exist)"
echo "==============================="
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "SSH key generated."
else
    echo "SSH key already exists, skipping…"
fi
