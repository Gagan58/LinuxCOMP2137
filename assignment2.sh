#!/bin/bash

# Function to print section headers
print_section() {
    echo "======================================================================"
    echo "$1"
    echo "======================================================================"
}

# Function to print commands before executing them
run_command() {
    echo "\$ $1"
    eval "$1"
}

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to add user with SSH keys and home directory
add_user() {
    local username="$1"
    local ssh_key="$2"
    run_command "sudo useradd -m -s /bin/bash $username"
    run_command "sudo mkdir -p /home/$username/.ssh"
    run_command "sudo sh -c 'echo \"$ssh_key\" >> /home/$username/.ssh/authorized_keys'"
    run_command "sudo chown -R $username:$username /home/$username/.ssh"
    run_command "sudo chmod 700 /home/$username/.ssh"
    run_command "sudo chmod 600 /home/$username/.ssh/authorized_keys"
}

# Function to add user to sudo group
add_sudo_user() {
    local username="$1"
    run_command "sudo usermod -aG sudo $username"
}

# Function to configure network interface
configure_network() {
    local netplan_file="/etc/netplan/01-netcfg.yaml"
    local config="
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          dhcp4: no
          addresses:
            - 192.168.16.21
          gateway4: 192.168.16.2
          nameservers:
            addresses: [192.168.16.2]
            search: [home.arpa, localdomain]
    "
    echo "$config" | sudo tee "$netplan_file" > /dev/null
    run_command "sudo netplan apply"
}

# Function to configure firewall
configure_firewall() {
    run_command "sudo ufw allow OpenSSH"
    run_command "sudo ufw allow http"
    run_command "sudo ufw allow 3128" # squid proxy
    run_command "sudo ufw enable"
}

# Main script starts here
print_section "Adding users and configuring SSH"

# Add users with SSH keys
add_user "dennis" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
add_user "aubrey" "<aubrey's_ssh_key>"
add_user "captain" "<captain's_ssh_key>"
add_user "snibbles" "<snibbles's_ssh_key>"
add_user "brownie" "<brownie's_ssh_key>"
add_user "scooter" "<scooter's_ssh_key>"
add_user "sandy" "<sandy's_ssh_key>"
add_user "perrier" "<perrier's_ssh_key>"
add_user "cindy" "<cindy's_ssh_key>"
add_user "tiger" "<tiger's_ssh_key>"
add_user "yoda" "<yoda's_ssh_key>"

# Add sudo access for dennis
add_sudo_user "dennis"

print_section "Configuring network interface"
configure_network

print_section "Installing required software"
# Install apache2 if not installed
if ! is_installed "apache2"; then
    run_command "sudo apt update"
    run_command "sudo apt install -y apache2"
fi

# Install squid if not installed
if ! is_installed "squid"; then
    run_command "sudo apt update"
    run_command "sudo apt install -y squid"
fi

print_section "Configuring firewall"
configure_firewall

echo "Script execution completed successfully."
