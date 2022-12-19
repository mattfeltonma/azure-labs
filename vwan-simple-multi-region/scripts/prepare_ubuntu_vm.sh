#!/bin/bash

# Add Azure CLI repository
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

#   Update repositories
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
