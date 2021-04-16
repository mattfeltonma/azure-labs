#!/bin/bash

# Update APT index and add repos
sudo apt -y update

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
sudo echo -e %central\ it@$2'\t' ALL=\(ALL\) '\t' ALL > sudo /etc/sudoers.d/domain_admins
sudo echo -e %domain\ admins@$2'\t' ALL=\(ALL\) '\t' ALL > sudo /etc/sudoers.d/domain_admins
