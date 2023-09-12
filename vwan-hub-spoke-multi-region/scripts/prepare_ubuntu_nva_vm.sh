#!/bin/bash

#   Update repositories
echo "Updating repositories" >> /var/log/provisioning.log
export DEBIAN_FRONTEND=dialog
apt -o DPkg::Lock::Timeout=60 clean
apt -o DPkg::Lock::Timeout=60 update

#   Run again to account for apt-update failure that seems to occur occasionally
echo "Updating repositories" >> /var/log/provisioning.log
export DEBIAN_FRONTEND=dialog
apt -o DPkg::Lock::Timeout=60 clean
apt -o DPkg::Lock::Timeout=60 update

#   Disable built-in firewall. Management will be done direct with iptables
ufw disable

#   Install net tools
export DEBIAN_FRONTEND=dialog
echo "Installing net-tools" >> /var/log/provisioning.log
apt-get -o DPkg::Lock::Timeout=30 install net-tools -y

#   Install support for persistency to iptables
echo "Installing iptables-persistent" >> /var/log/provisioning.log
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -o DPkg::Lock::Timeout=30 install iptables-persistent -y

#   Add kernal modules to support vrfs
echo "Installing linux-modules-extra-azure" >> /var/log/provisioning.log
apt-get -o DPkg::Lock::Timeout=30 install linux-modules-extra-$(uname -r) -y

#   Enable IPv4 forwarding
echo "Setting up ip forwarding" >> /var/log/provisioning.log
sed -r -i 's/#{1,}?net.ipv4.ip_forward ?= ?(0|1)/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

#   Enable vrf support in network stacks
echo "Enabling vrfs" >> /var/log/provisioning.log
sysctl -p | grep -i "net.ipv4.tcp_l3"
if [ $? -eq 1 ]
then
    echo "net.ipv4.tcp_l3mdev_accept = 1" >> /etc/sysctl.conf
    echo "net.ipv4.udp_l3mdev_accept = 1" >> /etc/sysctl.conf
    sysctl -p
fi

#   Configure routing
echo "Creating startup file to configure routing" >> /var/log/provisioning.log
ls -l /etc/systemd/system/routingconfig.service
if [ $? -eq 2 ]
then
    cat << EOF |
[Unit]
Description=Configure vrf and routing for machine

[Service]
Type=oneshot
RemainAfterExit=yes

ExecStart=/bin/bash -c "ip link add vrflan type vrf table 10"
ExecStart=/bin/bash -c "ip link set dev vrflan up"
ExecStart=/bin/bash -c "ip link set dev eth1 master vrflan"
ExecStart=/bin/bash -c "sleep 5"
ExecStart=/bin/bash -c "ip route add table 10 0.0.0.0/0 via $4"
ExecStart=/bin/bash -c "ip route add table 10 168.63.129.16 via $3"
ExecStart=/bin/bash -c "ip route add table 10 $1 via $3"
ExecStart=/bin/bash -c "ip route add table 10 $2 via $3"
ExecStart=/bin/bash -c "ip route add table 10 unreachable default metric 4278198272"
ExecStart=/bin/bash -c "ip route add $1 dev vrflan"
ExecStart=/bin/bash -c "ip route add $2 dev vrflan"

[Install]
WantedBy=multi-user.target
EOF
    awk '{print}' > /etc/systemd/system/routingconfig.service

    systemctl daemon-reload
    systemctl start routingconfig.service
    systemctl enable routingconfig.service
fi

#   Install and configure Quagga
echo "Installing quagga" >> /var/log/provisioning.log
apt-get -o DPkg::Lock::Timeout=30 install quagga -y

echo "Configuring quagga" >> /var/log/provisioning.log
ls -l /var/log/zebra.log > /dev/null
if [ $? -eq 2 ]
then
    mkdir -p /var/log/quagga && sudo chown quagga:quagga /var/log/quagga
    touch /var/log/zebra.log
    chown quagga:quagga /var/log/zebra.log
    touch /etc/quagga/babeld.conf
    touch /etc/quagga/bgpd.conf
    touch /etc/quagga/isisd.conf
    touch /etc/quagga/ospf6d.conf
    touch /etc/quagga/ospfd.conf
    touch /etc/quagga/ripd.conf
    touch /etc/quagga/ripngd.conf
    touch /etc/quagga/vtysh.conf
    touch /etc/quagga/zebra.conf
    chown quagga:quagga /etc/quagga/babeld.conf && sudo chmod 640 /etc/quagga/babeld.conf
    chown quagga:quagga /etc/quagga/bgpd.conf && sudo chmod 640 /etc/quagga/bgpd.conf
    chown quagga:quagga /etc/quagga/isisd.conf && sudo chmod 640 /etc/quagga/isisd.conf
    chown quagga:quagga /etc/quagga/ospf6d.conf && sudo chmod 640 /etc/quagga/ospf6d.conf
    chown quagga:quagga /etc/quagga/ospfd.conf && sudo chmod 640 /etc/quagga/ospfd.conf
    chown quagga:quagga /etc/quagga/ripd.conf && sudo chmod 640 /etc/quagga/ripd.conf
    chown quagga:quagga /etc/quagga/ripngd.conf && sudo chmod 640 /etc/quagga/ripngd.conf
    chown quagga:quaggavty /etc/quagga/vtysh.conf && sudo chmod 660 /etc/quagga/vtysh.conf
    chown quagga:quagga /etc/quagga/zebra.conf && sudo chmod 640 /etc/quagga/zebra.conf
    echo 'zebra=yes' > /etc/quagga/daemons
    echo 'bgpd=yes' >> /etc/quagga/daemons
    echo 'ospfd=no' >> /etc/quagga/daemons
    echo 'ospf6d=no' >> /etc/quagga/daemons
    echo 'ripd=no' >> /etc/quagga/daemons
    echo 'ripngd=no' >> /etc/quagga/daemons
    echo 'isisd=no' >> /etc/quagga/daemons
    echo 'babeld=no' >> /etc/quagga/daemons
    echo "add zebra config"
    
# # Create zebra config file
    cat <<EOF > /etc/quagga/zebra.conf
!
interface eth1
!
interface lo
!
table 10
!
ip forwarding
!
log file /var/log/quagga/quagga.log
!
line vty
!
EOF

# # Create bgpd config file
    cat <<EOF > /etc/quagga/bgpd.conf
!
router bgp $6
 bgp router-id $5
!
 address-family ipv6
 exit-address-family
 exit
!
log file /var/log/quagga/quagga.log
!
line vty
!
EOF
# # Configure Quagga to run in the vrf
    sed -r -i 's/\/usr\/sbin\/bgpd -d -A 127\.0\.0\.1 -f \/etc\/quagga\/bgpd\.conf/ip vrf exec vrflan \/usr\/sbin\/bgpd -d -A 127\.0\.0\.1 -f \/etc\/quagga\/bgpd\.conf/g' /lib/systemd/system/bgpd.service

# # Start Quagga services
    systemctl daemon-reload
    systemctl enable zebra.service
    systemctl enable bgpd.service
    systemctl start zebra 
    systemctl start bgpd  
fi

#   Configure iptables
echo "Configuring iptables" >> /var/log/provisioning.log
if ! iptables -v -L | grep vrflan >> /dev/null; then

    # # Configure support for NAT for Internet-bound traffic
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

    # # Allow and forward traffic out of vrf (LAN) to eth0 (Internet)
    iptables -A FORWARD -i eth0 -o vrflan -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i vrflan -o eth0 -j ACCEPT

    # # Allow and forward traffic between eth1 (LAN) and vrf (LAN)
    iptables -A FORWARD -i eth1 -o vrflan -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i vrflan -o eth1 -j ACCEPT

    # # Log traffic that is dropped
    iptables -A FORWARD -i eth0 -j LOG --log-prefix "Connection refused: "
    iptables -A FORWARD -i eth0 -j DROP

    # # Allow SSH traffic in eth0 and eth1
    iptables -A INPUT -p tcp --dport ssh --tcp-flags SYN,ACK SYN,ACK -j LOG --log-prefix "SSH Connection established: "
    iptables -A INPUT -p tcp --dport ssh -j ACCEPT

    # # Allow return traffic across all interfaces
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # # Drop all other traffic sent directly to routers
    iptables -A INPUT -i eth0 -j LOG --log-prefix "Connection refused: "
    iptables -A INPUT -i eth0 -j DROP

    # # Allow return traffic from sessions that interact with processes running on machine (such as ssh)
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # # Make the iptable rules persistent
    sudo -i
    sudo iptables-save > /etc/iptables/rules.v4
    exit
fi