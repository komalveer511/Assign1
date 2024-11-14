#!/bin/bash

# Set variables for hostname and network configurations
HOSTNAME="autosrv"
STATIC_IP="192.168.16.21/24"
GATEWAY="192.168.16.1"
DNS="192.168.16.1"
SEARCH_DOMAINS="home.arpa localdomain"
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Set the hostname
echo "Setting hostname to $HOSTNAME"
sudo hostnamectl set-hostname "$HOSTNAME"
echo "**Hostname configured successfully**"

# Configure static IP address
echo "Configuring static IP address: $STATIC_IP"
sudo bash -c "cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $STATIC_IP
    gateway $GATEWAY
    dns-nameservers $DNS
    dns-search $SEARCH_DOMAINS
EOF"
echo "**Network configuration set successfully**"

# Update system and install required software
echo "Updating package list and installing required software"
sudo apt update
sudo apt-get install -y openssh-server apache2 squid ufw
echo "**Software installation completed successfully**"

# Configure SSH server to disable password authentication
echo "Configuring SSH to disable password authentication"
sudo sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "**SSH configuration updated successfully**"

# Configure and enable Apache2 web server
echo "Configuring Apache2 web server"
sudo ufw allow in "Apache Full"
sudo systemctl enable apache2
echo "**Apache2 web server configured successfully**"

# Configure Squid web proxy to allow all HTTP access
echo "Configuring Squid proxy to allow HTTP access for all"
sudo sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf
sudo systemctl enable squid
echo "**Squid proxy configured successfully**"

# Configure firewall settings
echo "Configuring firewall rules"
sudo ufw allow ssh
sudo ufw allow https
sudo ufw allow http
sudo ufw allow 3128
echo "y" | sudo ufw enable
echo "**Firewall configured successfully**"

# Create user accounts
echo "Creating user accounts"
for user in "${USERS[@]}"; do
    sudo useradd -m -s /bin/bash "$user"
    echo "User account created: $user"
done
echo "**User accounts created successfully**"

# Set up SSH keys for each user
echo "Setting up SSH keys for each user"
for user in "${USERS[@]}"; do
    sudo mkdir -p /home/$user/.ssh
    sudo ssh-keygen -t rsa -f /home/$user/.ssh/id_rsa -N '' -q
    sudo ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N '' -q
    sudo cat /home/$user/.ssh/*.pub > /home/$user/.ssh/authorized_keys
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/*
    sudo chown -R $user:$user /home/$user/.ssh
    echo "SSH keys configured for user: $user"
done
echo "**SSH key setup completed successfully**"
