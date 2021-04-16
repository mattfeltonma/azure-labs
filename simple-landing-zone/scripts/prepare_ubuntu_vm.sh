#!/bin/bash

# Install Azure CLI
sudo apt-get update
sudo apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get -y install azure-cli

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Docker
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Install Expect
sudo apt-get -y install expect

# Add repos
sudo tee -a /etc/apt/sources.list <<EOF
deb
http://us.archive.ubuntu.com/ubuntu/
bionic universe
deb
http://us.archive.ubuntu.com/ubuntu/
bionic-updates universe
EOF

# Set server hostname
sudo hostnamectl set-hostname "${1}.${2}"

# Install required packages
sudo apt update
sudo apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit expect

# Retrieve the domain admin credentials
az login --identity --allow-no-subscriptions
AD_PASSWORD=$(az keyvault secret show --name=$3 --vault-name=$5 --query="value" --output=tsv)
AD_USERNAME=$(az keyvault secret show --name=$4 --vault-name=$5 --query="value" --output=tsv)

# Setup Docker permissions
sudo usermod -aG docker $AD_USERNAME

# Join the Ubuntu server to the AD domain
/usr/bin/expect << EOD
spawn sudo realm join -U $AD_USERNAME $2
expect "Password for ${AD_USERNAME}: "
send "${AD_PASSWORD}\r"
expect "* Resolving:"
EOD

# Enable home directory support
sudo bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF

sudo pam-auth-update --enable mkhomedir
sudo systemctl restart sssd

# Enable domain users to login
sudo realm permit -g 'Domain Users'

# Enable domain admins and central it to sudo
sudo echo -e %central\ it@$2'\t' ALL=\(ALL\) '\t' ALL >> /etc/sudoers.d/domain_admins
sudo echo -e %domain\ admins@$2'\t' ALL=\(ALL\) '\t' ALL >> /etc/sudoers.d/domain_admins
