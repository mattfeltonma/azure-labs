#!/bin/bash

# Add Azure CLI repository
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    tee /etc/apt/sources.list.d/azure-cli.list

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

#   Update repositories
export DEBIAN_FRONTEND=dialog
apt-get -o DPkg::Lock::Timeout=60 update

#   Update repositories again to address any delays with the Azure provisioning portion
export DEBIAN_FRONTEND=dialog
apt-get -o DPkg::Lock::Timeout=60 update

#   Disable built-in firewall. Management will be done direct with iptables
ufw disable

#   Install net tools
export DEBIAN_FRONTEND=noninteractive
apt-get -o DPkg::Lock::Timeout=30 install net-tools -y

# Install Azure CLI
apt-get  -o DPkg::Lock::Timeout=30 -y install ca-certificates curl apt-transport-https lsb-release gnupg
apt-get  -o DPkg::Lock::Timeout=30 -y install azure-cli

# Install Docker
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
apt-get -y install docker-ce docker-ce-cli containerd.io
usermod -aG docker $1

# Install kubectl
curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl